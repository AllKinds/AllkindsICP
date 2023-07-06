import { actor } from '$lib/stores';
import type { QuestionID } from 'src/declarations/backend/backend.did';
import { get } from 'svelte/store';
import { syncAuth } from './auth';

export async function skipQ(id: QuestionID) {
	const localActor = get(actor);
	console.log(id, '= gonna be skipped');
	await localActor.submitSkip(id).then((res) => console.log('Res after Q skipped :', res));
	await syncAuth();
}
