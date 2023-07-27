import { actor } from '$lib/stores';
import type { Gender, UserMatch } from 'src/declarations/backend/backend.did';
import { get, writable } from 'svelte/store';
import { syncAuth } from './auth';
import { showError, addNotification } from '$lib/utilities/notifications';

export const matchedUser = writable<UserMatch | undefined>();

export async function getMatchedUser(
    minAge: number,
    maxAge: number,
    gender: [] | [Gender],
    cohesion: number,
) {
    const localActor = get(actor);

    const res = await localActor.findMatch(minAge, maxAge, gender, cohesion);
    if ('ok' in res) {
        matchedUser.set(res.ok);
        console.log('matched users', res.ok);
    } else if ('err' in res) {
        matchedUser.set(undefined);
        console.log('error in findMatch:', res);
        showError(res.err)
    } else {
        matchedUser.set(undefined);
        console.error(res);
    }

    await syncAuth();
}
// let result = await localActor.getUser();
// if (result.hasOwnProperty('ok')) {
// 	user.set(result.ok);
// 	authStore.set(AuthState.Registered);
// } else if (result.hasOwnProperty('err')) {
// 	user = writable<User>();
// 	authStore.set(AuthState.LoggedIn);
// } else {
// 	console.error(result);
// }
