import { actor } from '$lib/stores';
import type { MatchingFilter, UserMatch } from 'src/declarations/backend/backend.did';
import { get, writable } from 'svelte/store';

export const matchedUser = writable<UserMatch>();

export async function getMatchedUser(filter: MatchingFilter) {
	const localActor = get(actor);

	return await localActor.findMatch(filter).then((res) => {
		console.log('matched user: ', res.ok);
		console.log(res);
		if (res.ok) {
			matchedUser.set(res.ok);
		}
	});
}
