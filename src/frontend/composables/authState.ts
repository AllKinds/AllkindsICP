import { createActor } from "../../declarations/backend";
import { AuthClient } from "@dfinity/auth-client";
import { HttpAgent } from "@dfinity/agent";
import { type BackendActor } from "~/utils/backend";
import { toNetworkError } from "~/utils/errors";
import { addNotification, inBrowser } from "./appState";
import { type Result, toErr } from "../utils/result";
import { type FrontendError } from "../utils/errors";

export type Provider = "II" | "NFID";

function loginUrl(provider: Provider) {
    const config = useRuntimeConfig().public;
    if (provider === "NFID") return config.NFID_URL;

    // default
    return config.II_URL;
}

type AuthState = {
    loggedIn: boolean, // cached status
    backendActor?: BackendActor;
}

type PRes<T> = Promise<Result<T, FrontendError>>

export const useAuthState = defineStore({
    id: 'auth',
    state: (): AuthState => {
        return {
            loggedIn: false,
            backendActor: undefined,
        }
    },
    actions: {
        setClient(loggedIn: boolean = true): void {
            this.loggedIn = loggedIn;
        },
        getClient(): AuthClient | null {
            return client
        },
        logout() {
            if (!client) return;
            client.logout();
            this.backendActor = undefined;
            client = null;
            this.loggedIn = false;
        },
        actor(orRedirect: boolean = true): BackendActor | undefined {
            if (!this.backendActor && client) {
                const config = useRuntimeConfig().public;
                const identity = client.getIdentity();
                console.log("restore actor from client:");
                if (identity.getPrincipal().toString().length > 10) {
                    // Using the identity obtained from the auth client, we can create an agent to interact with the IC.
                    const agent = new HttpAgent({ identity: identity, host: config.host });

                    // Using the interface description of our webapp, we create an actor that we use to call the service methods.
                    (window as any).global = window;
                    this.backendActor = createActor(config.canisterIds.backend, {
                        agent,
                    });
                }
            }
            if (!this.backendActor) {
                if (orRedirect) navTo("/login");
                return undefined;
            }
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
    if (!inBrowser()) throw ("not in browser");
    if (useAuthState().loggedIn) { return useAuthState().actor(false)! };
    const config = useRuntimeConfig().public;
    const agent = new HttpAgent({ host: config.host });
    (window as any).global = window;
    const anon = createActor(config.canisterIds.backend, { agent });
    return anon;
}

let client: AuthClient | null = null;

export const loginTest = (provider: Provider): PRes<AuthClient> => {
    const config = useRuntimeConfig().public;

    let resolver: any;
    client?.login({
        identityProvider: loginUrl(provider),
        onSuccess: () => {
            resolver(toOk(client));
        },
        onError: (e) => {
            console.error("login failed", e);
            addNotification("error", "Login failed");
            resolver(toErr(toNetworkError("login failed")));
        },
        // 7 days in nanoseconds
        maxTimeToLive: BigInt(7 * 24 * 60 * 60 * 1000 * 1000 * 1000),
        derivationOrigin: config.isDev ? undefined : config.FRONTEND_URL,
    });

    return new Promise((resolve: any) => {
        resolver = (val: unknown) => { resolve(val) }
    })
};

export const checkAuth = async (orLogin: boolean = true): PRes<boolean> => {
    if (!inBrowser()) { return Promise.resolve(toOk(true)) };

    client = client ?? await newAuthClient();
    try {
        let loggedIn = await client.isAuthenticated();
        if (!loggedIn && orLogin) { navTo("/login") }
        else if (loggedIn && client) {
            useAuthState().setClient(loggedIn)
        }
        return toOk(loggedIn);
    } catch (e) {
        return toErr(toNetworkError(e));
    };
};
