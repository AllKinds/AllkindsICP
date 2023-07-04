import { actor } from '$lib/stores';
import type { FriendStatus, UserMatch } from 'src/declarations/backend/backend.did';
import { get, writable } from 'svelte/store';

//export const foundFriends = writable<Array<FriendlyUserMatch>>();
export const friendsApproved = writable<Array<[UserMatch, FriendStatus]>>([]);
export const friendsWaiting = writable<Array<[UserMatch, FriendStatus]>>([]);
export const friendsRequested = writable<Array<[UserMatch, FriendStatus]>>([]);
//Requested could also be made

export async function getFriends() {
    friendsApproved.set([]);
    friendsWaiting.set([]);
    friendsRequested.set([]);
    const localActor = get(actor);

    await localActor.getFriends().then((res) => {
        console.log(res);
        if ('ok' in res) {
            //foundFriends.set(res.ok);
            const arr = res.ok;
            const approvedFriends = arr.filter((entry) => 'connected' in entry[1]);
            const waitingFriends = arr.filter((entry) => 'requestReceived' in entry[1]);
            const requestedFriends = arr.filter((entry) => 'requestSend' in entry[1]);

            friendsApproved.set(approvedFriends);
            friendsWaiting.set(waitingFriends);
            friendsRequested.set(requestedFriends);

            //derive stores
        }
    });
    //await syncAuth();
}
