import { actor } from '$lib/stores';
import type { FriendlyUserMatch, MatchingFilter } from 'src/declarations/backend/backend.did';
import { get, writable } from 'svelte/store';
import { syncAuth } from './auth';

export const matchedUser = writable<FriendlyUserMatch>();

export async function getMatchedUser(filter: MatchingFilter) {
	const localActor = get(actor);

	await localActor.findMatch(filter).then((res) => {
		console.log('matched user: ', res.ok);
		console.log(res);
		if (res.ok) {
			matchedUser.set(res.ok);
		}
	});
	await syncAuth();
}
