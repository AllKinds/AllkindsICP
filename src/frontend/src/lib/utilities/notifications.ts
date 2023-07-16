
import type { Error } from 'src/declarations/backend/backend.did';
import { writable } from 'svelte/store';

const empty: string[] = [];

export const notifications = writable(empty);

export function clearNotifications() {
    notifications.set(empty);
};

export function addNotification(msg: string) {
    console.log('Notification add:', msg);
    notifications.update((current) => { current.push(msg); return current });
    setTimeout(() => {
        notifications.update((current) => { current.pop(); return current });
        console.log('Notification removed:', msg);
    }, 2500);
}

export function addError(err: Error) {

    switch (Object.keys(err)[0]) {
        case 'notLoggedIn': addNotification("Not logged in"); break;
        case 'validationError': addNotification("Validation error"); break;
        case 'userNotFound': addNotification("User not found"); break;
        case 'tooLong': addNotification("Too long"); break;
        case 'insufficientFunds': addNotification("Insufficient funds"); break;
        case 'notEnoughAnswers': addNotification("Not enough answers"); break;
        case 'tooShort': addNotification("Too short"); break;
        case 'friendAlreadyConnected': addNotification("Friend already connected"); break;
        case 'nameNotAvailable': addNotification("Name not available"); break;
        case 'alreadyRegistered': addNotification("Already registered"); break;
        case 'friendRequestAlreadySend': addNotification("Friend request already send"); break;
        case 'notRegistered': addNotification("Not registered"); break;
        case 'invalidColor': addNotification("Invalid color"); break;
        default:
            console.error("Unhandled error:", err);
            addNotification(Object.keys(err)[0]);
            break;
    }
}