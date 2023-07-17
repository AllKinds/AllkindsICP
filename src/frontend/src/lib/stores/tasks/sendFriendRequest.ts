import { actor } from '$lib/stores';
import { get } from 'svelte/store';
import { syncAuth } from './auth';
import { addError } from '$lib/utilities/notifications';

export async function sendFriendRequest(p: string) {
	const localActor = get(actor);
	console.log('Request connect to :', p);
	await localActor
		.sendFriendRequest(p)
		.then((res) => {
            console.log('connection request response:', res)
            if ('err' in res) addError(res.err);
        });
	//getQs()
	await syncAuth();
}
