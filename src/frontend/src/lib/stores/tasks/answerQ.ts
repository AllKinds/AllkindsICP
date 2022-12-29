import { actor } from '$lib/stores';
import type { AnswerKind, Hash } from 'src/declarations/backend/backend.did';
import { get } from 'svelte/store';

export async function answerQ(hash: Hash, answer: AnswerKind) {
	const localActor = get(actor);
	console.log(hash, ' = gonna be answered with: ', answer);
	await localActor
		.submitAnswer(hash, answer)
		.then((res) => console.log('Res after Q skipped :', res));
}
