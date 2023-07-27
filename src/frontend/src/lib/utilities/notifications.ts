
import type { Error } from 'src/declarations/backend/backend.did';
import { writable } from 'svelte/store';

const empty: [string, boolean][] = [];

export const notifications = writable(empty);

export function clearNotifications() {
    notifications.set([]);
};

export function addNotification(msg: string, isError: boolean) {
    console.log('Notification add:', msg);
    notifications.update((current) => { current.push([msg, isError]); return current });
    setTimeout(() => {
        notifications.update((current) => { current.pop(); return current });
        console.log('Notification removed:', msg);
    }, 2500);
}

export function showError(err: Error) {

    switch (Object.keys(err)[0]) {
        case 'notLoggedIn': addNotification("Not logged in", true); break;
        case 'validationError': addNotification("Validation error", true); break;
        case 'userNotFound': addNotification("User not found", true); break;
        case 'tooLong': addNotification("Too long", true); break;
        case 'insufficientFunds': addNotification("Insufficient funds", true); break;
        case 'notEnoughAnswers': addNotification("Not enough answers", true); break;
        case 'tooShort': addNotification("Too short", true); break;
        case 'friendAlreadyConnected': addNotification("Friend already connected", true); break;
        case 'nameNotAvailable': addNotification("Name not available", true); break;
        case 'alreadyRegistered': addNotification("Already registered", true); break;
        case 'friendRequestAlreadySend': addNotification("Friend request already send", true); break;
        case 'notRegistered': addNotification("Not registered", true); break;
        case 'invalidColor': addNotification("Invalid color", true); break;
        default:
            console.error("Unhandled error:", err);
            addNotification(Object.keys(err)[0], true);
            break;
    }
}

export function showResult(res: { err: Error } | { ok: any }, success: string) {
    if ('err' in res) { showError(res.err) }
    else { addNotification(success, false) }
}