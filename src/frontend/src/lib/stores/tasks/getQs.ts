import { actor } from '$lib/stores';
import type { Question } from 'src/declarations/backend/backend.did';
import { get, writable } from 'svelte/store';

export const questions = writable<Array<Question>>();

export async function getQs() {
    const localActor = get(actor);
    if (!localActor) { setTimeout(getQs, 100); return; } // TODO: retry when actor is created
    const nr = BigInt(5);
    await localActor.getAskableQuestions(nr).then((qs) => {
        console.log('questions: ', qs);
        if (qs) {
            questions.set(qs);
        }
    });
    //await syncAuth();
}
