import { actor } from '$lib/stores';
import type { FriendlyUserMatch, MatchingFilter } from 'src/declarations/backend/backend.did';
import { get, writable } from 'svelte/store';
import { syncAuth } from './auth';

export var matchedUser = writable<FriendlyUserMatch>();

export async function getMatchedUser(filter: MatchingFilter) {
	const localActor = get(actor);

	let res = await localActor.findMatch(filter);
	if (res.hasOwnProperty('ok')) {
		matchedUser.set(res.ok);
		console.log('matched users', res.ok);
	} else if (res.hasOwnProperty('err')) {
		matchedUser = writable<FriendlyUserMatch>();
		console.log('err : ', res);
	} else {
		console.error(res);
	}

	await syncAuth();
}
// let result = await localActor.getUser();
// if (result.hasOwnProperty('ok')) {
// 	user.set(result.ok);
// 	authStore.set(AuthState.Registered);
// } else if (result.hasOwnProperty('err')) {
// 	user = writable<User>();
// 	authStore.set(AuthState.LoggedIn);
// } else {
// 	console.error(result);
// }
