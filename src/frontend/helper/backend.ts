import { backend } from "~~/src/declarations/backend";
export type { Error as BackendError } from "~~/src/declarations/backend/backend.did";
export type * from "~~/src/declarations/backend/backend.did";
export type BackendActor = typeof backend;

// TODO: this should be auto generated:
export type ErrorKey =
    "notLoggedIn"
    | "validationError"
    | "userNotFound"
    | "tooLong"
    | "insufficientFunds"
    | "notEnoughAnswers"
    | "tooShort"
    | "friendAlreadyConnected"
    | "nameNotAvailable"
    | "alreadyRegistered"
    | "friendRequestAlreadySend"
    | "notRegistered"
    | "invalidColor";

export function formatError(err: Error): string {
    const key = Object.keys(err)[0] as ErrorKey;

    switch (key) {
        case "validationError":
            return "Validation error";
        case "userNotFound":
            return "User not found";
        case "tooLong":
            return "Too long";

        default:
            return "Error " + key;
    }
}
