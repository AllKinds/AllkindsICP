import { actor } from '$lib/stores';
import type { Question } from 'src/declarations/backend/backend.did';
import { get, writable } from 'svelte/store';

export const questions = writable<Array<Question>>();

export async function getQs() {
	const localActor = get(actor);
	let nr: bigint = BigInt(5);
	return await localActor.getAskableQuestions(nr).then((res) => {
		console.log('questions: ', res.ok);
		if (res.ok) {
			questions.set(res.ok);
		}

		//questions.set(res.ok)
	});

	// if (result.hasOwnProperty('ok')) {
	//   console.log('ok', result.ok[0])
	//   result.ok
	// } else if (result.hasOwnProperty('err')) {
	//   console.log('err', result)
	// } else {
	// 	console.error('else', result);
	// }
}
