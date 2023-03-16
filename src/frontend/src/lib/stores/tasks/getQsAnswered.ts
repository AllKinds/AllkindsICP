import { actor } from '$lib/stores';
import type { Question } from 'src/declarations/backend/backend.did';
import { get, writable } from 'svelte/store';

export const questionsAnswered = writable<Array<Question>>();

export async function getQsAnswered() {
	const localActor = get(actor);
	let nr: bigint = BigInt(5);
	return await localActor.getAnsweredQuestions(nr).then((res) => {
		console.log('answered questions: ', res.ok);
		if (res.ok) {
			questionsAnswered.set(res.ok);
		}
	});
}
