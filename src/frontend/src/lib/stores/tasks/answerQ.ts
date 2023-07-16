import { actor } from '$lib/stores';
import type { QuestionID } from 'src/declarations/backend/backend.did';
import { get } from 'svelte/store';
import { syncAuth } from './auth';
import { addError } from '$lib/utilities/notifications';

export async function answerQ(id: QuestionID, answer: boolean, weight: bigint) {
    const localActor = get(actor);
    console.log(id, ' = gonna be answered with: ', answer);
    await localActor
        .submitAnswer(id, answer, weight)
        .then((res) => {
            console.log('Res after Q skipped:', res)
            if ('err' in res) addError(res.err);
        });
    await syncAuth();
}
