import { actor } from '$lib/stores';
import type { Principal } from '@dfinity/principal';
import { get } from 'svelte/store';

export async function sendFriendRequest(p: Principal) {
	const localActor = get(actor);
	console.log('Request connect to :', p);
	await localActor
		.sendFriendRequest(p)
		.then((res) => console.log('connection request response:', res));
	//getQs()
}
