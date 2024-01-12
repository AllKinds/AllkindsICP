import { createActor } from "../../declarations/backend";
import { AuthClient } from "@dfinity/auth-client";
import { HttpAgent } from "@dfinity/agent";
import { BackendActor } from "~/utils/backend";
import { toNetworkError } from "~/utils/errors";
import { inBrowser } from "./appState";
import { toErr } from "../utils/result";
import { navigateTo } from "../../../.nuxt/imports";

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
        async check(orLogin: boolean = true): Promise<Result<boolean>> {
            if (!inBrowser()) { return Promise.resolve(toOk(true)) };

            this.client = this.client ?? await newAuthClient();
            try {
                this.loggedIn = await this.client.isAuthenticated();
                if (!this.loggedIn && orLogin) navigateTo("/login");
                return toOk(this.loggedIn);
            } catch (e) {
                return toErr(toNetworkError(e));
            };
        },
        login(provider: Provider): Promise<Result<void>> {
            return new Promise<Result<void>>(async (resolve, reject) => {
                this.client = await newAuthClient();

                this.client.login({
                    identityProvider: loginUrl(provider),
                    onSuccess: () => {
                        this.loggedIn = true;
                        resolve(toOk(undefined));
                    },
                    onError: (e) => resolve(toErr(toNetworkError("Could not log in: " + e))),
                    // 7 days in nanoseconds
                    maxTimeToLive: BigInt(7 * 24 * 60 * 60 * 1000 * 1000 * 1000),
                });
            });
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
                this.backendActor = createActor(config.canisterIds.backend, {
                    agent,
                });
            }
            if (!this.backendActor && orRedirect) { navigateTo("/login") }
            return this.backendActor as BackendActor;
        },

        anonActor(): BackendActor {
            if (this.backendActor) { return this.backendActor as BackendActor };
            console.log("auth.actor is null, creating unauthenticated actor")
            const config = useRuntimeConfig().public;
            const agent = new HttpAgent({ host: config.host });
            const anon = createActor(config.canisterIds.backend, { agent });
            return anon;
        }
    }
});

const newAuthClient = (anon = false): Promise<AuthClient> => {
    return AuthClient.create({
        idleOptions: { disableIdle: true, disableDefaultIdleCallback: true }
    });
};


export const loginTest = (provider: Provider): Promise<Result<void>> => {
    return new Promise<Result<void>>(async (resolve, reject) => {
        const client = await newAuthClient();

        client.login({
            identityProvider: loginUrl(provider),
            onSuccess: () => {
                useAuthState().loggedIn = true;
                resolve(toOk(undefined));
            },
            onError: (e) => resolve(toErr(toNetworkError("Could not log in: " + e))),
            // 7 days in nanoseconds
            maxTimeToLive: BigInt(7 * 24 * 60 * 60 * 1000 * 1000 * 1000),
        });
    });
};
