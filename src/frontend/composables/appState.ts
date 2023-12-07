import { Effect, pipe } from "effect";
import { FrontendEffect, Question, Answer, User, Friend } from "~/utils/backend";
import * as backend from "~/utils/backend";
import { FrontendError, notifyWithMsg } from "~/utils/errors";
import { defineStore } from 'pinia'
import * as errors from "~/utils/errors";

export type AppState = {
    user: NetworkData<User>,
    openQuestions: NetworkData<Question[]>,
    answeredQuestions: NetworkData<Friend[]>,
    ownQuestions: NetworkData<Question[]>,
    friends: NetworkData<Friend[]>,
};

type NotificationLevel = "ok" | "warning" | "error";

export type DataStatus = "init" | "requested" | "error" | "ok";
export type NetworkData<T> = {
    status: DataStatus;
    data?: T;
    lastOK?: Date;
    err?: FrontendError;
    lastErr?: Date;
    errCount: number;
};
const dataInit: NetworkData<any> = {
    status: "init",
    data: undefined,
    lastOK: undefined,
    err: undefined,
    lastErr: undefined,
    errCount: 0,
}


type FrontendEffectToEffect<A> = (effect: FrontendEffect<A>) => FrontendEffect<A>;

const setRequested = <A>(old: NetworkData<A>): NetworkData<A> => {
    return {
        status: "requested",
        data: undefined,
        err: old.err,
        errCount: old.errCount,
    };
}

const setOk = <A>(data: A): NetworkData<A> => {
    return {
        status: "ok",
        data,
        lastOK: new Date(),
        errCount: 0,
    }
}

const setErr = <A>(old: NetworkData<A>, err: FrontendError): NetworkData<A> => {
    return {
        status: "error",
        err,
        lastErr: new Date(),
        errCount: 1,
    }
}

export const storeToData = <A>(old: NetworkData<A>, effect: FrontendEffect<A>, store: (a: NetworkData<A>) => void): FrontendEffect<A> => {
    store(setRequested(old));
    const before = Effect.sync<void>(() => {
        console.log("requesting")
    })
    const after = Effect.mapBoth<FrontendError, A, FrontendError, A>({
        onSuccess: (a) => {
            console.log("request ok")
            store(setOk(undefined as A));
            store(setRequested(old));
            setTimeout(() => store(setOk(a)));
            return a;
        },
        onFailure: (e) => {
            console.log("request error")
            store(setErr(old, e))
            return e;
        },
    })
    return pipe(
        before,
        () => effect,
        after
    )
}

export const runStoreNotify = <A>(old: NetworkData<A>, effect: FrontendEffect<A>, store: (a: NetworkData<A>) => void, msg?: string): Promise<A> => {
    console.log(effect)
    return Effect.runPromise(
        storeToData(
            old,
            pipe(effect, notifyWithMsg(msg)),
            store,
        )
    );
}


export const runStore = <A>(old: NetworkData<A>, effect: FrontendEffect<A>, store: (a: NetworkData<A>) => void, msg?: string): Promise<A> => {
    return Effect.runPromise(
        storeToData(
            old,
            effect,
            store,
        )
    );
}

export const runNotify = <A>(effect: FrontendEffect<A>, msg?: string): Promise<A> => {
    const dummy: NetworkData<A> = { status: "init", errCount: 0 };
    return runStoreNotify(dummy, effect, (_) => { }, msg);
}

const combineNetworkData = <A>(old: NetworkData<A>, newer: NetworkData<A>): NetworkData<A> => {
    switch (newer.status) {
        case "ok": return newer;
        case "error":
        case "requested": return { ...newer, data: old.data, lastOK: old.lastOK };
        case "init": throw "combineNetworkData should never be called with init as new value"
    }
}


const defaultAppState: AppState = {
    user: dataInit,
    openQuestions: dataInit,
    answeredQuestions: dataInit,
    ownQuestions: dataInit,
    friends: dataInit,
};

export const useAppState = defineStore({
    id: 'app',
    state: (): AppState => defaultAppState,
    actions: {
        getOpenQuestions(): NetworkData<Question[]> {
            return this.openQuestions as NetworkData<Question[]>; // TODO remove `as ...`
        },
        setOpenQuestions(qs: NetworkData<Question[]>): void {
            const { openQuestions } = storeToRefs(this)
            openQuestions.value = combineNetworkData(this.openQuestions, qs);
        },
        removeQuestion(q: Question): void {
            const data = this.openQuestions as NetworkData<Question[]>
            if (data.data) {
                const i = data.data.findIndex((x) => x.id === q.id);
                if (1 >= 0) {
                    console.log("index of", q, "is", i, "in", this.openQuestions.data)
                    data.data.splice(i, 1);
                }
            }
            this.setOpenQuestions({ status: "requested", errCount: 0 });
            setTimeout(() => this.setOpenQuestions(data));
        },
        loadQuestions(maxAgeS?: number, msg?: string) {
            if (shouldUpdate(this.openQuestions, maxAgeS)) {
                const old = this.getOpenQuestions();
                runStoreNotify(old, backend.loadQuestions(), this.setOpenQuestions, msg)
            }
        },
        getAnsweredQuestions(): NetworkData<[Question, Answer][]> {
            return this.answeredQuestions as NetworkData<[Question, Answer][]>; // TODO remove `as ...`
        },
        setAnsweredQuestions(qs: NetworkData<[Question, Answer][]>): void {
            const { answeredQuestions } = storeToRefs(this)
            let old = this.answeredQuestions as NetworkData<[Question, Answer][]>;
            answeredQuestions.value = combineNetworkData(old, qs);
        },
        loadAnsweredQuestions(maxAgeS?: number): void {
            if (shouldUpdate(this.answeredQuestions, maxAgeS)) {
                const old = this.getAnsweredQuestions();
                runStoreNotify(old, backend.getAnsweredQuestions(), this.setAnsweredQuestions)
            }
        },
        getOwnQuestions(): NetworkData<Question[]> {
            return this.ownQuestions as NetworkData<Question[]>; // TODO remove `as ...`
        },
        setOwnQuestions(qs: NetworkData<Question[]>): void {
            const { ownQuestions } = storeToRefs(this)
            ownQuestions.value = combineNetworkData(this.ownQuestions, qs);
        },
        loadOwnQuestions(maxAgeS?: number): void {
            if (shouldUpdate(this.ownQuestions, maxAgeS)) {
                const old = this.getOwnQuestions();
                runStoreNotify(old, backend.getOwnQuestions(), this.setOwnQuestions)
            }
        },
        getUser() {
            return withDefault(this.user, {} as User);
        },
        setUser(user: NetworkData<User>): void {
            this.user = combineNetworkData(this.user, user)
        },
        loadUser(orRedirect: boolean = true) {
            if (shouldUpdate(this.user)) {
                runStore(this.user, backend.loadUser().pipe(Effect.mapError(
                    (err) => {
                        if (!orRedirect) return err;
                        if (errors.is(err, "backend", "notRegistered")) navigateTo("/register");
                        if (errors.is(err, "backend", "notLoggedIn")) navigateTo("/login");
                        return err;
                    }
                )), this.setUser)
                    .catch((e) => console.warn("couldn't loadUser " + e));
            }
        },
        getFriends() {
            return this.friends as NetworkData<Friend[]>; // TODO remove `as ...`
        },
        setFriends(friends: NetworkData<Friend[]>): void {
            const old = this.friends as NetworkData<Friend[]>
            this.friends = combineNetworkData(old, friends)
        },
        loadFriends() {
            if (shouldUpdate(this.friends)) {
                runStore(this.friends, backend.loadFriends(), this.setFriends)
                    .catch(console.error);
            }
        },
    },
});

const withDefault = <T>(data: NetworkData<T>, fallback: T): T => {
    return data.data || fallback;
};

const shouldUpdate = <T>(data: NetworkData<T>, maxAgeS?: number): boolean => {
    switch (data.status) {
        case "init":
            return true;

        case "requested":
            return false;

        case "error":
            // TODO?: wait between errors?
            return true;

        case "ok":
            const limit = Date.now().valueOf() - ((maxAgeS || 30) * 1000);
            if (data.lastOK!.valueOf() < limit) {
                return true;
            }
            return false;
    }
}

export const addNotification = (level: NotificationLevel, msg: string): void => {
    switch (level) {
        case "ok": console.log("notification (" + level + "): " + msg); break;
        case "warning": console.warn("notification (" + level + "): " + msg); break;
        case "error": console.error("notification (" + level + "): " + msg); break;
    }
    if (!process.client) {
        return;
    }
    const toast = useNuxtApp().$toast;
    switch (level) {
        case "ok": toast.success(msg, { autoClose: 1000 }); break;
        case "warning": toast.warning(msg); break;
        case "error": toast.error(msg); break;
    }
}

export const inBrowser = (fn?: () => unknown): boolean => {
    if (fn !== undefined) {
        if (process.client) fn();
    }
    return !!process.client
}