import { actor } from '$lib/stores';
import type { Question } from 'src/declarations/backend/backend.did';
import { get, writable } from 'svelte/store';
import { toNullable } from '../../utilities/index';
import { syncAuth } from './auth';

export const questionsAnswered = writable<Array<Question>>();

export async function getQsAnswered() {
	const localActor = get(actor);
	let nr = toNullable(BigInt(20));
	//currently get 20, (null = all)
	await localActor.getAnsweredQuestions(nr).then((res) => {
		console.log('answered questions: ', res.ok);
		if (res.ok) {
			questionsAnswered.set(res.ok);
		}
	});
	await syncAuth();
}
