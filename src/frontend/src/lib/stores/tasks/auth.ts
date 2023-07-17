import { fromNullable } from '$lib/utilities';
import { Actor, HttpAgent, type Identity } from '@dfinity/agent';
import { AuthClient } from '@dfinity/auth-client';
import type { Principal } from '@dfinity/principal';
import type { ResultUser, User } from 'src/declarations/backend/backend.did';
import { get, writable } from 'svelte/store';
import { idlFactory } from '../../../../../declarations/backend';
import { AuthState, type BackendActor } from '../types';
import { addError } from '$lib/utilities/notifications';

export const authStore = writable<AuthState>();
export const actor = writable<BackendActor>();
const noUser: User = {
    username: '-',
    created: BigInt(0),
    about: [[], false],
    socials: [],
    gender: [[], false],
    picture: [[], false],
    age: [[], false],
    points: BigInt(0)
};
export const user = writable<User>(noUser);
export const avatar = writable<string | ArrayBuffer | null | undefined>();
export const caller = writable<Principal>();
let authClient: AuthClient;

//NFID
// Your application's name (URI encoded)
const APPLICATION_NAME = 'Allkinds';

// URL to 37x37px logo of your application (URI encoded)
const APPLICATION_LOGO_URL = 'https://nfid.one/icons/favicon-96x96.png';

const AUTH_PATH =
    '/authenticate/?applicationName=' +
    APPLICATION_NAME +
    '&applicationLogo=' +
    APPLICATION_LOGO_URL +
    '#authorize';

// Replace https://identity.ic0.app with NFID_AUTH_URL
// as the identityProvider for authClient.login({})
const NFID_AUTH_URL = 'https://nfid.one' + AUTH_PATH;

// let authClient: AuthClient = await AuthClient.create();

// (await authClient.isAuthenticated())
// 	? await checkRegistration()
// 	: authStore.set(AuthState.LoggedOut);
export async function start() {
    authClient = await AuthClient.create();

    if (await authClient.isAuthenticated()) {
        await checkRegistration();
    } else {
        authStore.set(AuthState.LoggedOut);
    }
}
start();

async function createActor() {
    const isAuthenticated = await authClient.isAuthenticated();

    if (!isAuthenticated) {
        return;
    }

    const identity: Identity = authClient.getIdentity();

    const agent = new HttpAgent({
        identity,
        host: import.meta.env.VITE_HOST
    });

    // Fetch root key for certificate validation during development
    if (import.meta.env.VITE_DFX_NETWORK !== 'ic') {
        agent.fetchRootKey().catch((err) => {
            console.warn('Unable to fetch root key. Check to ensure that your local replica is running');
            console.error(err);
        });
    }

    const localActor: BackendActor = Actor.createActor(idlFactory, {
        agent,
        canisterId: import.meta.env.VITE_BACKEND_CANISTER_ID
    });

    actor.set(localActor);
}

async function checkRegistration(): Promise<void> {
    await createActor();
    const localActor = get(actor);
    const p = await localActor.whoami();
    const result: ResultUser = await localActor.getUser();
    if ('ok' in result) {
        user.set(result.ok);
        authStore.set(AuthState.Registered);
        caller.set(p);
        console.log(p);

        const userData = get(user);
        const a = fromNullable(userData.picture[0]);
        if (a != undefined) {
            const image = new Uint8Array(a);
            const blob = new Blob([image], { type: 'image/png' });
            const reader = new FileReader();
            reader.readAsDataURL(blob);
            reader.onload = (res) => {
                avatar.set(res.target?.result);
            };
            console.log(avatar);
        } else {
            avatar.set(null);
        }
    } else if ('err' in result) {
        user.set(noUser);
        authStore.set(AuthState.LoggedIn);
    } else {
        console.error('invalid return value', result);
    }
}
user;

export async function syncAuth() {
    const isAuthenticated = await authClient.isAuthenticated();
    isAuthenticated ? await checkRegistration() : authStore.set(AuthState.LoggedOut);
}

export async function login() {
    await authClient.login({
        identityProvider:
            import.meta.env.VITE_DFX_NETWORK === 'ic'
                ? NFID_AUTH_URL
                : "http://" + import.meta.env.VITE_INTERNET_IDENTITY_CANISTER_ID +
                "." + import.meta.env.VITE_HOST.replace(/^https?:../, ''),
        onSuccess: async () => await checkRegistration()
    });
}

export async function logout() {
    await authClient.logout();
    authStore.set(AuthState.LoggedOut);
}
