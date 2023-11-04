import type { Error as BackendError } from "~~/src/declarations/backend/backend.did";
export type { Error as BackendError } from "~~/src/declarations/backend/backend.did";

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

export type ErrorTags = "backend" | "network"
export type FrontendError = { tag: "backend", err: BackendError }
    | { tag: "network", err: string }
    | { tag: "env", err: string }
    | { tag: "notLoggedIn" }

export const toNetworkError = (e: any): FrontendError => {
    return { tag: "network", err: "" + e };
}

export const toBackendError = (e: BackendError): FrontendError => {
    return { tag: "backend", err: e };
}

export const notLoggedIn: BackendError = { notLoggedIn: null }