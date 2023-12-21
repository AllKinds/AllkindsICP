import { Effect } from "effect";
import type { Error as BackendError } from "~~/src/declarations/backend/backend.did";
import { FrontendEffect } from "./backend";
export type { Error as BackendError } from "~~/src/declarations/backend/backend.did";

// TODO: this should be auto generated:
export type ErrorKey =
    "notLoggedIn"
    | "validationError"
    | "userNotFound"
    | "tooLong"
    | "notInTeam"
    | "invalidInvite"
    | "teamNotFound"
    | "insufficientFunds"
    | "notEnoughAnswers"
    | "tooShort"
    | "friendAlreadyConnected"
    | "nameNotAvailable"
    | "alreadyRegistered"
    | "friendRequestAlreadySend"
    | "notRegistered"
    | "invalidColor";


export function getErrorKey(err: BackendError): ErrorKey {
    const key = Object.keys(err)[0] as ErrorKey;
    return key;
}

export function formatBackendError(err: BackendError): string {
    const key = getErrorKey(err);

    switch (key) {
        case "validationError":
            return "Validation error";
        case "userNotFound":
            return "User not found";
        case "tooLong":
            return "Too long";
        case "notEnoughAnswers":
            return "Not enough answers"
        case "invalidInvite":
            return "Invite is not valid"

        // TODO: format other errors

        default:
            return "Error " + key;
    }
}
export function formatError(err: FrontendError): string {
    if (err.tag === "backend") {
        return formatBackendError(err.err)
    } else if (err.tag === "form") {
        return formatBackendError(err.err)
    } else if (err.tag === "notLoggedIn") {
        return "Not logged in"
    } else {
        return err.err;
    }
}

export type ErrorTags = "backend" | "network" | "env" | "deps" | "notLoggedIn" | "form";
export type FrontendError = { tag: "backend", err: BackendError }
    | { tag: "network", err: string }
    | { tag: "env", err: string }
    | { tag: "deps", err: string }
    | { tag: "notLoggedIn" }
    | { tag: "form", err: BackendError }

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

export const formErr = (key: ErrorKey): FrontendError => {
    let err: any = {};
    err[key] = null;
    return { tag: "form", err: err as BackendError }
}

const notifyWith = <R, A>(effect: Effect.Effect<R, FrontendError, A>, msg?: (a: A) => string): Effect.Effect<R, FrontendError, A> => {
    return Effect.mapBoth(effect, {
        onFailure: (e) => { addNotification("error", formatError(e)); return e; },
        onSuccess: (a) => { if (msg) addNotification("ok", msg(a)); return a; },
    })
}

const notifyMsg = <R, A>(effect: Effect.Effect<R, FrontendError, A>, msg?: string): Effect.Effect<R, FrontendError, A> => {
    return Effect.mapBoth(effect, {
        onFailure: (e) => { addNotification("error", formatError(e)); return e; },
        onSuccess: (a) => { if (msg) addNotification("ok", msg); return a; },
    })
}

export const notifyWithMsg = <A>(msg?: string): (effect: FrontendEffect<A>) => FrontendEffect<A> => {
    return (effect) => notifyMsg(effect, msg);
}

export const notifyWithFormatter = <A>(msg: (a: A) => string): (effect: FrontendEffect<A>) => FrontendEffect<A> => {
    return (effect) => notifyWith(effect, msg);
}

export const is = (err: FrontendError, tag: ErrorTags, key?: ErrorKey): boolean => {
    if (err.tag !== tag) return false;
    if (!key) return true;
    switch (err.tag) {
        case "backend": return getErrorKey(err.err) === key;
        case "form": return getErrorKey(err.err) === key;
        case "network": return true;
        case "deps": return true;
        case "env": return true;
        case "notLoggedIn": return true;
    }

    console.error("unhandled error tag " + tag)
    return false;
}
