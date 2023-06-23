import { fromNullable } from '$lib/utilities';
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
export let avatar = writable<any>();
export let caller = writable<Principal>();
let authClient: AuthClient;
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
	const p = await localActor.whoami();
	const result = await localActor.getUser();
	if (result.hasOwnProperty('ok')) {
		user.set(result.ok);
		authStore.set(AuthState.Registered);
		caller.set(p);
		console.log(p);

		let userData = get(user);
		let a = fromNullable(userData.picture[0]);
		if (a != undefined) {
			let image = new Uint8Array(a);
			let blob = new Blob([image], { type: 'image/png' });
			let reader = new FileReader();
			reader.readAsDataURL(blob);
			reader.onload = (res) => {
				avatar.set(res.target?.result);
			};
			console.log(avatar);
		} else {
			avatar.set(null);
		}
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
				: 'http://127.0.0.1:8080/?canisterId=q4eej-kyaaa-aaaaa-aaaha-cai',
		//local dev II has changed, broken for now
		onSuccess: async () => await checkRegistration()
	});
}

export async function logout() {
	await authClient.logout();
	authStore.set(AuthState.LoggedOut);
}
