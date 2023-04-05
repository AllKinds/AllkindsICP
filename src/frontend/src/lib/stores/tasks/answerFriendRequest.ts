import { actor } from '$lib/stores';
import type { Principal } from '@dfinity/principal';
import { get } from 'svelte/store';
import { syncAuth } from './auth';

export async function answerFriendRequest(p: Principal, b: boolean) {
	const localActor = get(actor);
	console.log('answering friendrequest connect to :', p);
	await localActor
		.answerFriendRequest(p, b)
		.then((res) => console.log('connection request response:', res));
	//getQs()
	await syncAuth();
}
