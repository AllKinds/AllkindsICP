import { actor } from '$lib/stores';
import type { User } from 'src/declarations/backend/backend.did';
import { get } from 'svelte/store';
import { syncAuth } from './auth';
import { showError } from '$lib/utilities/notifications';

export async function updateProfile(newUser: User) {
    const localActor = get(actor);
    console.log('newUserToSend', newUser);
    await localActor.updateProfile(newUser).then((res) => {
        console.log('res', res)
        if ('err' in res) showError(res.err);
    });
    await syncAuth();
}
