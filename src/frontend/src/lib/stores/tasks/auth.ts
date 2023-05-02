import { Actor, HttpAgent, type Identity } from '@dfinity/agent';
import { AuthClient } from '@dfinity/auth-client';
import type { Principal } from '@dfinity/principal';
import type { User } from 'src/declarations/backend/backend.did';
import { get, writable } from 'svelte/store';
import { idlFactory } from '../../../../../declarations/backend';
import { AuthState, type BackendActor } from '../types';

export const authStore = writable<AuthState>();
export let actor = writable<BackendActor>();
export let user = writable<User>();
export let caller = writable<Principal>();
let authClient: AuthClient;

// let authClient: AuthClient = await AuthClient.create();

// (await authClient.isAuthenticated())
// 	? await checkRegistration()
// 	: authStore.set(AuthState.LoggedOut);
async function start() {
	let authClient: AuthClient = await AuthClient.create();

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
		actor = writable<BackendActor>();
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
	let p = await localActor.whoami();
	let result = await localActor.getUser();
	if (result.hasOwnProperty('ok')) {
		user.set(result.ok);
		authStore.set(AuthState.Registered);
		caller.set(p);
		console.log(p);
	} else if (result.hasOwnProperty('err')) {
		user = writable<User>();
		authStore.set(AuthState.LoggedIn);
	} else {
		console.error(result);
	}
}

export async function syncAuth() {
	const isAuthenticated = await authClient.isAuthenticated();
	isAuthenticated ? await checkRegistration() : authStore.set(AuthState.LoggedOut);
}

export async function login() {
	await authClient.login({
		identityProvider:
			import.meta.env.VITE_DFX_NETWORK === 'ic'
				? 'https://identity.ic0.app/'
				: 'http://qhbym-qaaaa-aaaaa-aaafq-cai.localhost:8080/',
		onSuccess: async () => await checkRegistration()
	});
}

export async function logout() {
	await authClient.logout();
	authStore.set(AuthState.LoggedOut);
}
