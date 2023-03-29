import { actor } from '$lib/stores';
import type { FriendlyUserMatch } from 'src/declarations/backend/backend.did';
import { get, writable } from 'svelte/store';
import { syncAuth } from './auth';

export const foundFriends = writable<Array<FriendlyUserMatch>>();

export async function getFriends() {
	const localActor = get(actor);

	await localActor.getFriends().then((res) => {
		console.log('found friends: ', res.ok);
		console.log(res);
		if (res.ok) {
			foundFriends.set(res.ok);
		}
	});
	//await syncAuth();
}
