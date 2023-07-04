import { actor } from '$lib/stores';
import type { Question } from 'src/declarations/backend/backend.did';
import { get, writable } from 'svelte/store';
import { caller, syncAuth } from './auth';

export const answeredQuestions = writable<Array<Question>>();
export const myQuestions = writable<Array<Question>>();

export async function getQsAnswered() {
	const localActor = get(actor);
	const p = get(caller);

	await localActor.getAnsweredQuestions(BigInt(200)).then((qas) => {
		console.log('all answer questions: ', qas);
		if (qas) {
			//const answered = arr.filter((q: Question) => q.creater.toString() !== p.toString());
			const my = qas.filter((entry) => entry[0].creator.toString() === p.toString());
			answeredQuestions.set(qas.map((qa) => qa[0])); // same as answered
			myQuestions.set(my.map((qa) => qa[0]));
			console.log(p.toString());
			console.log('answered: ', qas);
			console.log('my questions: ', my);
		}
	});
	await syncAuth();
}
