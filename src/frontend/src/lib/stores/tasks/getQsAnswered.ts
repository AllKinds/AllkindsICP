import { actor } from '$lib/stores';
import type { Question } from 'src/declarations/backend/backend.did';
import { get, writable } from 'svelte/store';
import { caller, syncAuth } from './auth';

export const answeredQuestions = writable<Array<Question>>();
export const myQuestions = writable<Array<Question>>();

export async function getQsAnswered() {
	const localActor = get(actor);
	let p = get(caller);

	await localActor.getAnsweredQuestions().then((res) => {
		console.log('all answer questions: ', res.ok);
		if (res.ok) {
			let arr = res.ok;
			console.log(arr);
			//const answered = arr.filter((q: Question) => q.creater.toString() !== p.toString());
			const my = arr.filter((q: Question) => q.creater.toString() === p.toString());
			answeredQuestions.set(arr); // same as answered
			myQuestions.set(my);
			console.log(p.toString());
			console.log(arr[1].creater.toString());
			console.log('answered: ', arr);
			console.log('my questions: ', my);
		}
	});
	await syncAuth();
}
