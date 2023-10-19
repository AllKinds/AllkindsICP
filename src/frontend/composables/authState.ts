import { backend } from "../../declarations/backend";
import { createActor } from "~~/src/declarations/backend";
import { AuthClient } from "@dfinity/auth-client";
import { HttpAgent, Agent } from "@dfinity/agent";

export type Provider = "II" | "NFID";

function loginUrl(provider: Provider) {
    const config = useRuntimeConfig().public;
    if (provider === "NFID") return config.NFID_URL;

    // default
    return config.II_URL;
}

export async function checkAuth(loginWith: Provider | null): Promise<boolean> {
    // compatibility to webpack
    try {
        window.global ||= window;
    } catch (error) {
        console.error(error);
    }

    let authClient = await AuthClient.create();
    const config = useRuntimeConfig().public;

    if (!(await authClient.isAuthenticated())) {
        if (!loginWith) {
            // Return not logged in
            return false;
        } else {
            await new Promise((resolve) => {
                authClient.login({
                    identityProvider: loginUrl(loginWith),
                    onSuccess: () => resolve(null),
                });
            });
        }
    }

    const identity = authClient.getIdentity();
    // Using the identity obtained from the auth client, we can create an agent to interact with the IC.
    const agent = new HttpAgent({ identity });
    // Using the interface description of our webapp, we create an actor that we use to call the service methods.
    const actor = useState<typeof backend | null>("actor", () => null);
    actor.value = createActor(config.canisterIds.backend, {
        agent,
    });

    return true;
}

export const logoutActor = async () => {
    console.log("Logging out actor");
    let authClient = await AuthClient.create();
    console.log("Logging out actor: auth client created");

    const ret = await authClient.logout();
    console.log("Logging out actor: logout called:", ret);

    (await useActor()).value = null;
    console.log("Logging out actor: actor set to null:", await useActor());
};

export const useActor = async () => {
    await checkAuth(null);
    return useState<typeof backend | null>("actor", () => null);
};

export const isLoggedIn = async () => {
    return !!(await useActor()).value;
};
