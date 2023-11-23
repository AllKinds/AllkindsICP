import { backend, createActor } from "../../declarations/backend";
import { AuthClient } from "@dfinity/auth-client";
import { HttpAgent } from "@dfinity/agent";
import { Effect } from "effect";
import { BackendActor } from "~/utils/backend";
import { FrontendError, notLoggedIn, toBackendError, toNetworkError } from "~/utils/errors";

export type Provider = "II" | "NFID";

function loginUrl(provider: Provider) {
    const config = useRuntimeConfig().public;
    if (provider === "NFID") return config.NFID_URL;

    // default
    return config.II_URL;
}

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
        try: () => AuthClient.create(),
        catch: (e) => toNetworkError("Failed to create AuthClient: " + e),
    });

    //let authClient = await AuthClient.create();
    const config = useRuntimeConfig().public;

    const isAuthenticated = (a: AuthClient): Effect.Effect<never, FrontendError, boolean> =>
        Effect.tryPromise({
            try: () => a.isAuthenticated(),
            catch: toNetworkError,
        });

    function login(a: AuthClient, provider: Provider): Effect.Effect<never, FrontendError, void> {

        return Effect.async((resume) => {
            a.login({
                identityProvider: loginUrl(provider),
                onSuccess: (() => resume(Effect.succeed(null))),
                onError: ((e) => resume(Effect.fail(toNetworkError("Could not log in: " + e)))),
                maxTimeToLive: (BigInt(7 * 24 * 60 * 60 * 1000 * 1000 * 1000)), // 7 days
            });
        });
    }
    const actor = useState<typeof backend | null>("actor", () => null);

    const prog = Effect.gen(function* (_) {
        const client = yield* _(authClient);
        const isAuth = yield* _(isAuthenticated(client));
        if (!isAuth) {
            // return if login is not requested
            if (!loginWith) return false;

            yield* _(login(client, loginWith));
        }

        // return if login failed
        if (!(yield* _(isAuthenticated(client)))) return false;

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

export const logoutActor = (): Effect.Effect<never, never, void> => {
    console.log("Logging out actor");
    if (typeof window === "undefined") {
        return Effect.succeed(null);
    }

    return Effect.gen(function* (_) {
        const authClient = yield* _(Effect.promise(() => AuthClient.create()));
        yield* _(Effect.promise(() => authClient.logout()));
        useActor().value = null;
        return;
    });
};

export const useActor = (): Ref<typeof backend | null> => {
    return useState<typeof backend | null>("actor", () => null);
};

export const useActorOrLogin = (): Effect.Effect<never, FrontendError, BackendActor> => {
    return Effect.gen(function* (_) {
        yield* _(checkAuth(null));
        const actor = useActor();
        if (actor.value) return yield* _(Effect.succeed(actor.value));
        console.log("actor.value is null, redirecting to /login")
        navigateTo("/login");
        return yield* _(Effect.fail(toBackendError(notLoggedIn)));
    })
};

export const isLoggedIn = () => {
    console.log("actor ist", useActor().value);
    return !!useActor().value;
};
