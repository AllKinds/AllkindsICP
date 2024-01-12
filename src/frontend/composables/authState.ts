import { backend, createActor } from "../../declarations/backend";
import { AuthClient } from "@dfinity/auth-client";
import { HttpAgent } from "@dfinity/agent";
import { Effect } from "effect";
import { BackendActor } from "~/utils/backend";
import { FrontendError, notLoggedIn, toBackendError, toNetworkError } from "~/utils/errors";
import { isNumberObject } from "util/types";

export type Provider = "II" | "NFID";

function loginUrl(provider: Provider) {
    const config = useRuntimeConfig().public;
    if (provider === "NFID") return config.NFID_URL;

    // default
    return config.II_URL;
}

export const createAuthClient = async (anon: boolean = false, force: boolean = false) => {
    const client = useAuthClient(anon);
    if (client.value.tag === "ok" && !force) return;

    await newAuthClient(anon);
}

type AuthClientOrErr = Result<AuthClient>;
export const useAuthClient = (anon = false): Ref<AuthClientOrErr> => {
    if (anon) {
        return useState<AuthClientOrErr>("anonAuthClient", () => { return toErr(toNetworkError("init")) });
    } else {
        return useState<AuthClientOrErr>("authClient", () => { return toErr(toNetworkError("init")) });
    }
}

const newAuthClient = async (anon = false) => {
    await AuthClient.create({
        idleOptions: { disableIdle: true }
    }).then(
        (client) => { useAuthClient(anon).value = toOk(client) },
        (e) => {
            useAuthClient(anon).value = toErr(toNetworkError("Failed to create AuthClient: " + e))
        },
    )
}

// Check if user is logged in
// returns Effect which succeeds with true if user is logged in, false if not
export function checkAuth(
    loginWith: Provider | null
): Effect.Effect<never, FrontendError, boolean> {
    // compatibility to webpack
    try {
        if (typeof window === "undefined") {
            const err: FrontendError = { tag: "env", err: "not in browser" };
            return Effect.fail(err);
        }
        window.global ||= window;
    } catch (error) {
        console.error(error);
    }

    const authClient = Effect.tryPromise({
        try: () => AuthClient.create({
            idleOptions: { disableIdle: true }
        }),
        catch: (e) => toNetworkError("Failed to create AuthClient: " + e),
    });

    //let authClient = await AuthClient.create();
    const config = useRuntimeConfig().public;

    const isAuthenticated = (a: AuthClient): Effect.Effect<never, FrontendError, boolean> =>
        Effect.tryPromise({
            try: () => a.isAuthenticated(),
            catch: toNetworkError,
        });

    const actor = useActor();

    const prog = Effect.gen(function* (_) {
        const client = yield* _(authClient);
        const isAuth = yield* _(isAuthenticated(client));
        // return if not logged in
        if (!isAuth) { return false; }

        if (!actor.value) {
            const identity = client.getIdentity();
            // Using the identity obtained from the auth client, we can create an agent to interact with the IC.
            const agent = new HttpAgent({ identity: identity, host: config.host });

            // Using the interface description of our webapp, we create an actor that we use to call the service methods.
            actor.value = createActor(config.canisterIds.backend, {
                agent,
            });
        }

        return true;
    });

    return prog;
}

export const initiateLogin = (a: AuthClient, provider: Provider): Promise<void> => {
    console.log("start login with", provider);

    return new Promise((resolve, reject) =>
        a.login({
            identityProvider: loginUrl(provider),
            onSuccess: () => resolve(undefined),
            onError: (e) => reject("Could not log in: " + e),
            // 7 days in nanoseconds
            maxTimeToLive: BigInt(7 * 24 * 60 * 60 * 1000 * 1000 * 1000),
        })
    );

}

export const logoutActor = (): Effect.Effect<never, never, void> => {
    console.log("Logging out actor");
    if (!inBrowser()) {
        return Effect.succeed(null);
    }

    return Effect.gen(function* (_) {
        const authClient = yield* _(Effect.promise(() => AuthClient.create()));
        yield* _(Effect.promise(() => authClient.logout()));
        useActor().value = null;
        useAuthClient().value = toErr(toNetworkError("init"));
        return;
    });
};

export const useActor = (): Ref<typeof backend | null> => {
    return useState<typeof backend | null>("actor", () => null);
};

export const useActorOrLogin = (orRedirect: boolean = true): Effect.Effect<never, FrontendError, BackendActor> => {
    return Effect.gen(function* (_) {
        yield* _(checkAuth(null));
        const actor = useActor();
        if (actor.value) return yield* _(Effect.succeed(actor.value));
        if (orRedirect) {
            console.log("actor.value is null, redirecting to /login")
            navigateTo("/login");
        }
        return yield* _(Effect.fail(toBackendError(notLoggedIn)));
    })
};

export const useAnonActor = (): Effect.Effect<never, FrontendError, BackendActor> => {
    return Effect.gen(function* (_) {
        yield* _(checkAuth(null));
        const actor = useActor();
        if (actor.value) return yield* _(Effect.succeed(actor.value));
        console.log("actor.value is null, creating unauthenticated actor")
        const config = useRuntimeConfig().public;
        const agent = new HttpAgent({ host: config.host });
        const anon = createActor(config.canisterIds.backend, { agent });
        return yield* _(Effect.succeed(anon));
    })
};

export const isLoggedIn = () => {
    return !!useActor().value;
};
