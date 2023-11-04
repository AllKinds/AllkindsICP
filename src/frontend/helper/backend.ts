import { backend } from "~~/src/declarations/backend";
export type * from "~~/src/declarations/backend/backend.did";
export type BackendActor = typeof backend;
import { Effect } from "effect";
import { BackendError, FrontendError, toNetworkError } from "~/helper/errors";
import { Question } from "./backend";

type BackendEffect<T> = Effect.Effect<never, BackendError, T>
type FrontendEffect<T> = Effect.Effect<never, FrontendError, T>

export const loadQuestions = (): Effect.Effect<never, FrontendError, Question[]> => {
    return Effect.gen(function* (_) {
        const actor = yield* _(useActorOrLogin());
        const limit = BigInt(10);
        const questions = yield* _(Effect.tryPromise({
            try: () => actor.getAskableQuestions(limit),
            catch: toNetworkError
        }));
        return questions
    });
}

export const resultToEffect = <T>(result: { err: BackendError } | { ok: T }): BackendEffect<T> => {
    if ("err" in result) {
        return Effect.fail(result.err);
    } else {
        return Effect.succeed(result.ok);
    }
}

export const createQuestion = (q: string): FrontendEffect<void> => {
    return Effect.gen(function* (_) {
        const actor = yield* _(useActorOrLogin());
        const result = yield* _(Effect.tryPromise({
            try: () => actor.createQuestion(q, ""),
            catch: toNetworkError
        }));

    });
}
