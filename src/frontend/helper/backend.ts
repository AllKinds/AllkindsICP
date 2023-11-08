import { backend } from "~~/src/declarations/backend";
export type * from "~~/src/declarations/backend/backend.did";
export type BackendActor = typeof backend;
import { Effect } from "effect";
import { BackendError, FrontendError, toNetworkError } from "~/helper/errors";
import { Question } from "./backend";

type BackendEffect<T> = Effect.Effect<never, BackendError, T>
type FrontendEffect<T> = Effect.Effect<never, FrontendError, T>

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

export const loadQuestions = (): FrontendEffect<Question[]> => {
    const limit = BigInt(10);
    return effectify((actor) => actor.getAskableQuestions(limit))
}

export const createQuestion = (q: string): FrontendEffect<void> => {
    return effectify((actor) => actor.createQuestion(q, ""))
}

export const answerQuestion = (q: number, a: boolean, boost: number): FrontendEffect<void> => {
    return effectify((actor) => actor.submitAnswer(BigInt(q), a, BigInt(boost)));
}