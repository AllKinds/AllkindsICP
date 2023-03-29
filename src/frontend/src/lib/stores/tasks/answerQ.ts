import { actor } from '$lib/stores';
import type { Hash } from 'src/declarations/backend/backend.did';
import { get } from 'svelte/store';

export async function answerQ(hash: Hash, answer: boolean, weight: bigint) {
	const localActor = get(actor);
	console.log(hash, ' = gonna be answered with: ', answer);
	await localActor
		.submitAnswer(hash, answer, weight)
		.then((res) => console.log('Res after Q skipped :', res));
}
