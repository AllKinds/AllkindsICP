import { backend } from "../../declarations/backend";
import { createActor } from "~~/src/declarations/backend";
import { AuthClient } from "@dfinity/auth-client";
import { HttpAgent, Agent } from "@dfinity/agent";
import { Effect, pipe } from "effect";
import { EffectPrototype } from "effect/dist/declarations/src/Effectable";
import { isUint8Array } from "effect/dist/declarations/src/Predicate";

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

        const identity = client.getIdentity();
        // Using the identity obtained from the auth client, we can create an agent to interact with the IC.
        const agent = new HttpAgent({ identity });

        console.log("set auth client", actor.value, "to", agent);
        // Using the interface description of our webapp, we create an actor that we use to call the service methods.
        actor.value = createActor(config.canisterIds.backend, {
            agent,
        });

        return true;
    });

    return prog;
}

export const logoutActor = async () => {
    console.log("Logging out actor");
    try {
        if (typeof window === "undefined") {
            return Promise.resolve();
        }
    } catch (error) {
        console.error(error);
    }
    let authClient = await AuthClient.create();
    console.log("Logging out actor: auth client created");

    const ret = await authClient.logout();
    console.log("Logging out actor: logout called:", ret);

    (await useActor()).value = null;
    console.log("Logging out actor: actor set to null:", await useActor());
};

export const useActor = () => {
    return useState<typeof backend | null>("actor", () => null);
};

export const isLoggedIn = () => {
    console.log("actor ist", useActor().value);
    return !!useActor().value;
};
