
export type Result<T, E> = { ok: true, val: T } | { ok: false, err: E };

export const toOk = <T, E>(val: T): Result<T, E> => {
    return { ok: true, val: val };
}

export const toErr = <T, E>(err: E): Result<T, E> => {
    return { ok: false, err: err };
}
