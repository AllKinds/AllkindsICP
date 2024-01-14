import { backend } from "~~/src/declarations/backend";
export type { Principal } from "@dfinity/principal";
export type * from "~~/src/declarations/backend/backend.did";
export type BackendActor = typeof backend;
import { Effect } from "effect";
import type { Principal } from "@dfinity/principal";
import { BackendError, FrontendError, toBackendError, toNetworkError } from "~/utils/errors";
import type { Question, Answer, User, Skip, Friend, UserMatch, TeamUserInfo, TeamStats, QuestionStats, FriendStatus, UserPermissions } from "~~/src/declarations/backend/backend.did";
import { useAuthState } from "../composables/authState";

type BackendEffect<T> = Effect.Effect<never, BackendError, T>
export type FrontendEffect<T> = Effect.Effect<never, FrontendError, T>

export const resultToEffect = <T>(result: { err: BackendError } | { ok: T }): BackendEffect<T> => {
    if ("err" in result) {
        return Effect.fail(result.err);
    } else {
        return Effect.succeed(result.ok);
    }
}

const effectify = <T>(fn: (actor: BackendActor) => Promise<T>, orRedirect: boolean = true): FrontendEffect<T> => {
    return Effect.gen(function* (_) {
        yield* _(Effect.tryPromise({
            try: () => checkAuth(orRedirect),
            catch: toNetworkError
        }));
        const actor = useAuthState().actor(orRedirect);
        if (!actor) {
            yield* _(Effect.fail(toNetworkError("not logged in!")))
            // can't be reached because of Effect.fail above
            throw ("Unreachable code");
        }

        const result = yield* _(Effect.tryPromise({
            try: () => fn(actor),
            catch: toNetworkError
        }));
        return result;
    });
}

const effectifyAnon = <T>(fn: (actor: BackendActor) => Promise<T>): FrontendEffect<T> => {
    return Effect.gen(function* (_) {
        yield* _(Effect.tryPromise({
            try: () => checkAuth(false),
            catch: toNetworkError
        }));
        console.log("get anonActor");
        const actor = anonActor();
        const result = yield* _(Effect.tryPromise({
            try: () => fn(actor),
            catch: toNetworkError
        }));
        return result;
    });
}

const effectifyResult = <T>(fn: (actor: BackendActor) => Promise<{ ok: T } | { err: BackendError }>, orRedirect: boolean = true): FrontendEffect<T> => {
    return Effect.gen(function* (_) {
        const res = yield* _(effectify(fn, orRedirect));
        return yield* _(resultToEffect(res).pipe(Effect.mapError(toBackendError)));
    })
}

const effectifyAnonResult = <T>(fn: (actor: BackendActor) => Promise<{ ok: T } | { err: BackendError }>): FrontendEffect<T> => {
    return Effect.gen(function* (_) {
        const res = yield* _(effectifyAnon(fn));
        return yield* _(resultToEffect(res).pipe(Effect.mapError(toBackendError)));
    })
}

export const withDefault = <T>(data: NetworkData<T>, fallback: T): T => {
    return data.data || fallback;
};


export const loadOpenQuestions = (team: string): FrontendEffect<Question[]> => {
    const limit = BigInt(20);
    return effectify((actor) => actor.getUnansweredQuestions(team, limit))
}

export const getAnsweredQuestions = (team: string): FrontendEffect<[Question, Answer][]> => {
    const limit = BigInt(200);
    return effectify((actor) => actor.getAnsweredQuestions(team, limit))
}

export const getOwnQuestions = (team: string): FrontendEffect<Question[]> => {
    const limit = BigInt(200);
    return effectify((actor) => actor.getOwnQuestions(team, limit))
}

export const loadUser = (orRedirect = true): FrontendEffect<UserPermissions> => {
    return effectifyResult((actor) => actor.getUser(), orRedirect)
}

export const createQuestion = (team: string, q: string, c: ColorName): FrontendEffect<void> => {
    return effectifyResult((actor) => actor.createQuestion(team, q, c))
}

export const createUser = (name: string, contact: string): FrontendEffect<void> => {
    return effectifyResult((actor) => actor.createUser(name, contact))
}

export const answerQuestion = (team: string, q: BigInt, a: boolean, boost: number): FrontendEffect<Answer> => {
    return effectifyResult((actor) => actor.submitAnswer(team, q.valueOf(), a, BigInt(boost)));
}

export const skipQuestion = (team: string, q: BigInt): FrontendEffect<Skip> => {
    return effectifyResult((actor) => actor.submitSkip(team, q.valueOf()));
}

export const loadFriends = (team: string): FrontendEffect<Friend[]> => {
    return effectifyResult((actor) => actor.getFriends(team))
}

export const loadMatches = (team: string): FrontendEffect<UserMatch[]> => {
    return effectifyResult((actor) => actor.getMatches(team))
}

export const loadTeams = (known: string[]): FrontendEffect<TeamUserInfo[]> => {
    return effectifyAnonResult((actor) => actor.listTeams(known))
}

export const loadTeamStats = (team: string): FrontendEffect<TeamStats> => {
    return effectifyResult((actor) => actor.getTeamStats(team))
}

export const loadTeamMembers = (team: string): FrontendEffect<User[]> => {
    return effectifyResult((actor) => actor.getTeamMembers(team))
}

export const loadAdmins = (): FrontendEffect<UserPermissions[]> => {
    return effectifyResult((actor) => actor.listAdmins())
}

export const loadQuestionStats = (team: string): FrontendEffect<QuestionStats[]> => {
    const limit = BigInt(200);
    return effectifyResult((actor) => actor.getQuestionStats(team, limit))
}

export type FriendStatusKey = "requestSend"
    | "requestReceived"
    | "connected"
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
        case "requestReceived": return "request";
        case "requestSend": return "request pending";
    }
    console.error("Unexpected friend status", status);
    return "unknown";
}

export const friendStatusIcon = (status: FriendStatus): { icon: string, color: string } => {
    switch (friendStatusToKey(status)) {
        case "connected": return { icon: "tabler:user-check", color: "text-green-500" };
        case "rejectionReceived": return { icon: "tabler:user-x", color: "text-red-500" };
        case "rejectionSend": return { icon: "tabler:user-cancel", color: "text-red-600" };
        case "requestReceived": return { icon: "tabler:user-question", color: "text-orange-500" };
        case "requestSend": return { icon: "tabler:user-exclamation", color: "text-gray-500" };
    }
    console.error("Unexpected friend status", status);
    return { icon: "?", color: "" };
}

export const canSendFriendRequest = (status: FriendStatus): boolean => {
    switch (friendStatusToKey(status)) {
        case "connected": return false;
        case "rejectionReceived": return false;
        case "rejectionSend": return true;
        case "requestReceived": return true;
        case "requestSend": return false;
    }
}

export const canSendRemoveFriendRequest = (status: FriendStatus): boolean => {
    switch (friendStatusToKey(status)) {
        case "connected": return true;
        case "rejectionReceived": return false;
        case "rejectionSend": return false;
        case "requestReceived": return true;
        case "requestSend": return true;
    }
}



export const sendFriendRequest = (team: string, username: string): FrontendEffect<void> => {
    return effectifyResult((actor) => actor.sendFriendRequest(team, username))
}

export const answerFriendRequest = (team: string, username: string, accept: boolean): FrontendEffect<void> => {
    return effectifyResult((actor) => actor.answerFriendRequest(team, username, accept))
}

export const joinTeam = (team: string, code: string): FrontendEffect<void> => {
    return effectifyResult((actor) => actor.joinTeam(team, code))
}

export const leaveTeam = (team: string, user: string): FrontendEffect<void> => {
    return effectifyResult((actor) => actor.leaveTeam(team, user))
}

export const createTeam = (team: string, name: string, about: string, logo: number[], listed: boolean, code: string): FrontendEffect<void> => {
    return effectifyResult((actor) => actor.createTeam(team, code, { name, about, logo, listed }))
}

export const deleteQuestion = (team: string, question: Question): FrontendEffect<void> => {
    return effectifyResult((actor) => actor.deleteQuestion(team, question))
}

export const getOwnPrincipal = (): FrontendEffect<Principal> => {
    return effectify((actor) => actor.whoami())
}

