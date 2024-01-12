import { ok } from "assert";
import { FrontendError } from "./errors";

export type Result<T> = { tag: 'ok', val: T } | { tag: 'err', err: FrontendError };

export const toOk = <T>(val: T): Result<T> => {
    return { tag: 'ok', val: val };
}

export const toErr = <T>(err: FrontendError): Result<T> => {
    return { tag: 'err', err: err };
}
