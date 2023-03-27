import { actor } from '$lib/stores';
import type { Friend } from 'src/declarations/backend/backend.did';
import { get, writable } from 'svelte/store';

//export const matchedUsers = writable<Array<[User, BigInt]>>();
export const foundFriends = writable<Array<[Friend]>>();

export async function getFriends() {
	const localActor = get(actor);

	return await localActor.getFriends().then((res) => {
		console.log('found friends: ', res.ok);
		console.log(res);
		if (res.ok) {
			foundFriends.set(res.ok);
		}
	});
}
