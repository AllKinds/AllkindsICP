import { actor } from '$lib/stores';
import type { MatchingFilter, User } from 'src/declarations/backend/backend.did';
import { get, writable } from 'svelte/store';

export const matchedUsers = writable<Array<User>>();

export async function getMatchedUsers(filter: MatchingFilter) {
	const localActor = get(actor);

	return await localActor.findMatches(filter).then((res) => {
		console.log('matched users: ', res.ok);
		if (res.ok) {
			matchedUsers.set(res.ok);
		}
	});
}
