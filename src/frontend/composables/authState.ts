import { createActor } from "../../declarations/backend";
import { AuthClient } from "@dfinity/auth-client";
import { HttpAgent } from "@dfinity/agent";
import { BackendActor } from "~/utils/backend";
import { toNetworkError } from "~/utils/errors";
import { inBrowser } from "./appState";
import { Result, toErr } from "../utils/result";
import { navigateTo } from "../../../.nuxt/imports";
import { FrontendError } from "../utils/errors";

export type Provider = "II" | "NFID";

function loginUrl(provider: Provider) {
    const config = useRuntimeConfig().public;
    if (provider === "NFID") return config.NFID_URL;

    // default
    return config.II_URL;
}

type AuthState = {
    client?: AuthClient,
    loggedIn: boolean, // cached status
    backendActor?: BackendActor;
}

type PRes<T> = Promise<Result<T, FrontendError>>

export const useAuthState = defineStore({
    id: 'auth',
    state: (): AuthState => {
        return {
            client: undefined,
            loggedIn: false,
            backendActor: undefined,
        }
    },
    actions: {
        setClient(client: AuthClient): void {
            this.client = client;
            this.loggedIn = true;
        },
        getClient(): AuthClient | undefined {
            return this.client as AuthClient
        },
        logout() {
            if (!this.client) return;
            this.client.logout();
            this.client = undefined;
            this.backendActor = undefined;
            this.loggedIn = false;
        },
        actor(orRedirect: boolean = true): BackendActor | undefined {
            if (!this.backendActor && this.client) {
                const config = useRuntimeConfig().public;
                const identity = this.client.getIdentity();
                // Using the identity obtained from the auth client, we can create an agent to interact with the IC.
                const agent = new HttpAgent({ identity: identity, host: config.host });

                // Using the interface description of our webapp, we create an actor that we use to call the service methods.
                (window as any).global = window;
                this.backendActor = createActor(config.canisterIds.backend, {
                    agent,
                });
            }
            if (!this.backendActor && orRedirect) { navigateTo("/login") }
            return this.backendActor as BackendActor;
        },

    }
});

const newAuthClient = (anon = false): Promise<AuthClient> => {
    return AuthClient.create({
        idleOptions: { disableIdle: true, disableDefaultIdleCallback: true }
    });
};

export const anonActor = (): BackendActor => {
    if (!inBrowser()) return null!;
    if (useAuthState().loggedIn) { return useAuthState().actor()! };
    console.log("auth.actor is null, creating unauthenticated actor");
    const config = useRuntimeConfig().public;
    const agent = new HttpAgent({ host: config.host });
    (window as any).global = window;
    const anon = createActor(config.canisterIds.backend, { agent });
    return anon;
}

export const loginTest = (provider: Provider): PRes<AuthClient> => {
    return new Promise<Result<AuthClient, FrontendError>>(async (resolve, reject) => {
        const client = await newAuthClient();

        client.login({
            identityProvider: loginUrl(provider),
            onSuccess: () => {
                useAuthState().loggedIn = true;
                resolve(toOk(client));
            },
            onError: (e) => resolve(toErr(toNetworkError("Could not log in: " + e))),
            // 7 days in nanoseconds
            maxTimeToLive: BigInt(7 * 24 * 60 * 60 * 1000 * 1000 * 1000),
        });
    });
};

export const checkAuth = async (orLogin: boolean = true): PRes<boolean> => {
    if (!inBrowser()) { return Promise.resolve(toOk(true)) };

    const client: AuthClient = useAuthState().getClient() ?? await newAuthClient();
    try {
        let loggedIn = await client.isAuthenticated();
        if (!loggedIn && orLogin) { navigateTo("/login") }
        else if (loggedIn && client) {
            useAuthState().setClient(client)
        }
        return toOk(loggedIn);
    } catch (e) {
        return toErr(toNetworkError(e));
    };
};
