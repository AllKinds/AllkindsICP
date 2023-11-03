import { backend, createActor } from "../../declarations/backend";
import { AuthClient } from "@dfinity/auth-client";
import { HttpAgent, Agent } from "@dfinity/agent";
import { Effect, pipe } from "effect";
import { EffectPrototype } from "effect/dist/declarations/src/Effectable";
import { isUint8Array } from "effect/dist/declarations/src/Predicate";
import { BackendActor, BackendError } from "~/helper/backend";
import { FrontendError } from "~/helper/errors";

export type Provider = "II" | "NFID";

function loginUrl(provider: Provider) {
    const config = useRuntimeConfig().public;
    if (provider === "NFID") return config.NFID_URL;

    // default
    return config.II_URL;
}

export function checkAuth(
    loginWith: Provider | null
): Effect.Effect<never, Error, boolean> {
    // compatibility to webpack
    try {
        if (typeof window === "undefined") {
            return Effect.fail(new Error("Not in browser"));
        }
        window.global ||= window;
    } catch (error) {
        console.error(error);
    }

    const authClient = Effect.tryPromise({
        try: () => AuthClient.create(),
        catch: (e) => new Error("Failed to create AuthClient: " + e),
    });

    //let authClient = await AuthClient.create();
    const config = useRuntimeConfig().public;

    const isAuthenticated = (a: AuthClient) =>
        Effect.tryPromise({
            try: () => a.isAuthenticated(),
            catch: (e) => new Error("Failed to check authclient.isAuthenticated(): + " + e),
        });

    function login(a: AuthClient, provider: Provider): Effect.Effect<never, Error, void> {

        return Effect.async((resume) => {
            a.login({
                identityProvider: loginUrl(provider),
                onSuccess: (() => resume(Effect.succeed(null))),
                onError: ((e) => resume(Effect.fail(new Error("Could not log in: " + e)))),
                maxTimeToLive: BigInt(3_600_000_000_000) * BigInt(24) * BigInt(7), // 7 days
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

export const useActor = () => {
    return useState<typeof backend | null>("actor", () => null);
};

export const useActorOrLogin = (): Effect.Effect<never, FrontendError, BackendActor> => {
    const actor = useActor();
    if (actor.value) return Effect.succeed(actor.value);
    console.log("actor.value is null, redirecting to /login")
    navigateTo("/login");
    return Effect.fail({ tag: "notLoggedIn" });
};

export const isLoggedIn = () => {
    console.log("actor ist", useActor().value);
    return !!useActor().value;
};
