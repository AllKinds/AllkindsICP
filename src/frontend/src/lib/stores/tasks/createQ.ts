import { actor } from '$lib/stores';
import { get } from 'svelte/store';
import { syncAuth } from './auth';
//import { Color } from '../../../../../../.dfx/local/canisters/backend/backend.did';

export async function createQ(text: string, color: string) {
	const localActor = get(actor);
	console.log('New Q is gonna be created:', text, color);
	await localActor
		.createQuestion(text, color)
		.then((res) => console.log('Res after Q creation :', res));
	await syncAuth();
}
