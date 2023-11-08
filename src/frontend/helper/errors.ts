import { Effect } from "effect";
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

export function formatBackendError(err: BackendError): string {
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
export function formatError(err: FrontendError): string {
    if (err.tag === "backend") {
        return formatBackendError(err.err)
    } else if (err.tag === "notLoggedIn") {
        return "Not logged in"
    } else {
        return err.err;
    }
}

export type ErrorTags = "backend" | "network"
export type FrontendError = { tag: "backend", err: BackendError }
    | { tag: "network", err: string }
    | { tag: "env", err: string }
    | { tag: "deps", err: string }
    | { tag: "notLoggedIn" }

export const toNetworkError = (e: any): FrontendError => {
    return { tag: "network", err: "" + e };
}

export const toBackendError = (e: BackendError): FrontendError => {
    return { tag: "backend", err: e };
}

export const notLoggedIn: BackendError = { notLoggedIn: null }

export const depsErr = (err: string): FrontendError => {
    return {
        tag: "deps",
        err
    }
}

export const orNotify = <R, A>(effect: Effect.Effect<R, FrontendError, A>): Effect.Effect<R, FrontendError, A> => {
    return Effect.mapError(effect, (e) => {
        addNotification("error", formatError(e));
        return e;
    })
}