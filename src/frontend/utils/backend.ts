import { backend } from "~~/src/declarations/backend";
export type * from "~~/src/declarations/backend/backend.did";
export type BackendActor = typeof backend;
import { Effect } from "effect";
import { BackendError, FrontendError, toBackendError, toNetworkError } from "~/utils/errors";
import { Question, Answer, Skip, User, Friend, UserMatch } from "./backend";
import { FriendStatus } from "./backend";

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
    const limit = BigInt(20);
    return effectify((actor) => actor.getUnansweredQuestions(limit))
}

export const getAnsweredQuestions = (): FrontendEffect<[Question, Answer][]> => {
    const limit = BigInt(200);
    return effectify((actor) => actor.getAnsweredQuestions(limit))
}

export const getOwnQuestions = (): FrontendEffect<Question[]> => {
    const limit = BigInt(200);
    return effectify((actor) => actor.getOwnQuestions(limit))
}

export const loadUser = (): FrontendEffect<User> => {
    return effectifyResult((actor) => actor.getUser())
}

export const createQuestion = (q: string, c: ColorName): FrontendEffect<void> => {
    return effectifyResult((actor) => actor.createQuestion(q, c))
}

export const createUser = (name: string, contact: string): FrontendEffect<void> => {
    return effectifyResult((actor) => actor.createUser(name, contact))
}

export const answerQuestion = (q: BigInt, a: boolean, boost: number): FrontendEffect<Answer> => {
    return effectifyResult((actor) => actor.submitAnswer(q.valueOf(), a, BigInt(boost)));
}

export const skipQuestion = (q: BigInt): FrontendEffect<Skip> => {
    return effectifyResult((actor) => actor.submitSkip(q.valueOf()));
}

export const loadFriends = (): FrontendEffect<Friend[]> => {
    return effectifyResult((actor) => actor.getFriends())
}

export const loadMatches = (): FrontendEffect<UserMatch[]> => {
    return effectifyResult((actor) => actor.getMatches())
}

export type FriendStatusKey = "requestSend"
    | "requestReceived"
    | "connected"
    | "requestIgnored"
    | "rejectionSend"
    | "rejectionReceived";

export const friendStatusToKey = (status: FriendStatus): FriendStatusKey => {
    return Object.keys(status)[0] as FriendStatusKey;
}

export const formatFriendStatus = (status: FriendStatus): string => {
    switch (friendStatusToKey(status)) {
        case "connected": return "connected"
        case "rejectionReceived": return "rejected";
        case "rejectionSend": return "reject";
        case "requestIgnored": return "ignored";
        case "requestReceived": return "request";
        case "requestSend": return "requested";
    }
    console.error("Unexpected friend status")
    return "unknown"
}