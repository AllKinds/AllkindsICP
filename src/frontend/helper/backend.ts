import { backend } from "~~/src/declarations/backend";
export type * from "~~/src/declarations/backend/backend.did";
export type BackendActor = typeof backend;
import { Effect } from "effect";
import { BackendError, FrontendError, toBackendError, toNetworkError } from "~/helper/errors";
import { Question } from "./backend";
import { Answer } from "./backend";
import { Skip } from "./backend";

type BackendEffect<T> = Effect.Effect<never, BackendError, T>
export type FrontendEffect<T> = Effect.Effect<never, FrontendError, T>

export const resultToEffect = <T>(result: { err: BackendError } | { ok: T }): BackendEffect<T> => {
    if ("err" in result) {
        return Effect.fail(result.err);
    } else {
        return Effect.succeed(result.ok);
    }
}

const effectify = <T>(fn: (actor: BackendActor) => Promise<T>): FrontendEffect<T> => {
    return Effect.gen(function* (_) {
        const actor = yield* _(useActorOrLogin());
        const result = yield* _(Effect.tryPromise({
            try: () => fn(actor),
            catch: toNetworkError
        }));
        return result;
    });
}

const effectifyResult = <T>(fn: (actor: BackendActor) => Promise<{ ok: T } | { err: BackendError }>): FrontendEffect<T> => {
    return Effect.gen(function* (_) {
        const res = yield* _(effectify(fn));
        console.log("asdf", res);
        return yield* _(resultToEffect(res).pipe(Effect.mapError(toBackendError)));
    })
}

export const loadQuestions = (): FrontendEffect<Question[]> => {
    const limit = BigInt(10);
    return effectify((actor) => actor.getAskableQuestions(limit))
}

export const createQuestion = (q: string): FrontendEffect<void> => {
    return effectifyResult((actor) => actor.createQuestion(q, ""))
}

export const answerQuestion = (q: BigInt, a: boolean, boost: number): FrontendEffect<Answer> => {
    return effectifyResult((actor) => actor.submitAnswer(q.valueOf(), a, BigInt(boost)));
}

export const skipQuestion = (q: BigInt): FrontendEffect<Skip> => {
    return effectifyResult((actor) => actor.submitSkip(q.valueOf()));
}