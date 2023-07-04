import { actor } from '$lib/stores';
import { get } from 'svelte/store';
import { syncAuth } from './auth';

export async function answerFriendRequest(name: string, accept: boolean) {
	const localActor = get(actor);
	console.log('answering friend request connect to:', name);
	await localActor
		.answerFriendRequest(name, accept)
		.then((res) => console.log('connection request response:', res));
	//getQs()
	await syncAuth();
}
