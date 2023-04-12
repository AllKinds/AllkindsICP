import { actor } from '$lib/stores';
import type { FriendlyUserMatch } from 'src/declarations/backend/backend.did';
import { get, writable } from 'svelte/store';

//export const foundFriends = writable<Array<FriendlyUserMatch>>();
export const friendsApproved = writable<Array<FriendlyUserMatch>>();
export const friendsWaiting = writable<Array<FriendlyUserMatch>>();
export const friendsRequested = writable<Array<FriendlyUserMatch>>();
//Requested could also be made

export async function getFriends() {
	const localActor = get(actor);

	await localActor.getFriends().then((res) => {
		console.log('found friends: ', res.ok);
		console.log(res);
		if (res.ok) {
			//foundFriends.set(res.ok);
			let arr = res.ok;
			const approvedFriends = arr.filter(
				(f: FriendlyUserMatch) => Object.entries(f.status)[0][0] === 'Approved'
			);
			const waitingFriends = arr.filter(
				(f: FriendlyUserMatch) => Object.entries(f.status)[0][0] === 'Waiting'
			);
			const requestedFriends = arr.filter(
				(f: FriendlyUserMatch) => Object.entries(f.status)[0][0] === 'Requested'
			);

			friendsApproved.set(approvedFriends);
			friendsWaiting.set(waitingFriends);
			friendsRequested.set(requestedFriends);

			//derive stores
		}
	});
	//await syncAuth();
}
