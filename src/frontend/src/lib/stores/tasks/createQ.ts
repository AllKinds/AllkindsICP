import { actor } from '$lib/stores';
import { get } from 'svelte/store';
//import { Color } from '../../../../../../.dfx/local/canisters/backend/backend.did';

export async function createQ(text: string) {
	const localActor = get(actor);
	console.log('New Q is gonna be created:', text);
	await localActor.createQuestion(text).then((res) => console.log('Res after Q creation :', res));
	//getQs()
}
