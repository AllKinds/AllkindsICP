import { Effect, pipe } from "effect";
import type { Principal, FrontendEffect, Message, ChatStatus, Question, Answer, User, UserPermissions, Friend, UserMatch, TeamStats, TeamUserInfo, QuestionStats, UserNotifications } from "~/utils/backend";
import * as backend from "~/utils/backend";
import { type FrontendError, notifyWithMsg } from "~/utils/errors";
import { defineStore } from 'pinia'
import * as errors from "~/utils/errors";

export type AppState = {
  user: NetworkData<UserPermissions>,
  team: string,
  knownTeams: string[],
  openQuestions: NetworkData<Question[]>,
  answeredIds: bigint[],
  answeredQuestions: NetworkData<[Question, Answer][]>,
  ownQuestions: NetworkData<Question[]>,
  friends: NetworkData<Friend[]>,
  matches: NetworkData<UserMatch[]>,
  teams: NetworkData<TeamUserInfo[]>,
  principal: NetworkData<Principal>,
  teamStats: NetworkData<TeamStats>,
  questionStats: NetworkData<QuestionStats[]>,
  teamMembers: NetworkData<User[]>,
  teamAdmins: NetworkData<User[]>,
  admins: NetworkData<UserPermissions[]>
  users: NetworkData<UserNotifications[]>
  loadingCounter: number,
  answeredIdsReset?: any,
};

type NotificationLevel = "ok" | "warning" | "error";

export type DataStatus = "init" | "requested" | "error" | "ok";
export type NetworkData<T> = {
  status: DataStatus;
  data?: T;
  lastOK?: number;
  err?: FrontendError;
  errCount: number;
};
const dataInit: NetworkData<any> = {
  status: "init",
  data: undefined,
  lastOK: undefined,
  err: undefined,
  errCount: 0,
}
const networkDataToPromise = <T>(data: NetworkData<T>): Promise<T> => {
  if (data.status === "ok") return Promise.resolve(data.data!);
  if (data.status === "error") return Promise.reject(data.err);
  if (data.status === "requested" && data.lastOK) return Promise.reject(data.data!);

  // TODO: how to handle pending?
  return Promise.reject(data.err);
}


type FrontendEffectToEffect<A> = (effect: FrontendEffect<A>) => FrontendEffect<A>;

const setRequested = <A>(old: NetworkData<A>, reset: boolean): NetworkData<A> => {
  return {
    status: "requested",
    data: reset ? undefined : old.data,
    err: old.err,
    errCount: old.errCount,
  };
}

const setOk = <A>(data: A): NetworkData<A> => {
  return {
    status: "ok",
    data,
    lastOK: new Date().valueOf(),
    errCount: 0,
  }
}

const setErr = <A>(old: NetworkData<A>, err: FrontendError): NetworkData<A> => {
  return {
    status: "error",
    err,
    errCount: 1,
  }
}

export const storeToData = <A>(old: NetworkData<A>, effect: FrontendEffect<A>, store: (a: NetworkData<A>) => void, silent: boolean = false): FrontendEffect<A> => {
  if (!silent) store(setRequested(old, false));
  const before = Effect.sync<void>(() => {
    console.log("requesting")
  })
  const after = Effect.tapBoth<FrontendError, A, FrontendError, never, A, A, FrontendError, never>({
    onSuccess: (a) => {
      console.log("request ok")
      if (!silent) store(setRequested(old, true));
      setTimeout(() => store(setOk(a)));
      return Effect.succeed(a);
    },
    onFailure: (e) => {
      console.log("request error")
      store(setErr(old, e))
      return Effect.fail(e);
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


export const runStore = <A>(old: NetworkData<A>, effect: FrontendEffect<A>, store: (a: NetworkData<A>) => void, silent: boolean = false): Promise<A> => {
  return Effect.runPromise(
    storeToData(
      old,
      effect,
      store,
      silent,
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

export const inBrowser = (fn?: () => unknown): boolean => {
  if (fn !== undefined) {
    if (process.client) fn();
  }
  return !!process.client
}

/// @deprecated: use appData instead
const defaultAppState: () => AppState = () => {
  return {
    team: "",
    knownTeams: ["sandbox", "global", ""],
    loadingCounter: 0,
    answeredIdsReset: undefined,
    answeredIds: [],

    user: dataInit,
    openQuestions: dataInit,
    answeredQuestions: dataInit,
    ownQuestions: dataInit,
    friends: dataInit,
    matches: dataInit,
    teams: dataInit,
    principal: dataInit,
    teamStats: dataInit,
    questionStats: dataInit,
    teamMembers: dataInit,
    teamAdmins: dataInit,
    admins: dataInit,
    users: dataInit,

  }
};

/// @deprecated use getAppState() instead
export const appState = ref<AppState>(defaultAppState());

const initData = <T>() => ref<NetworkData<T>>(dataInit);
interface DataBy<T> { get: (group: string) => Ref<NetworkData<T>> };
const initDataBy = <T>(): DataBy<T> => {
  const store: { [group: string]: Ref<NetworkData<T>> } = {};
  return {
    get: (group: string) => {
      store[group] = store[group] ?? ref<NetworkData<T>>(dataInit);
      return store[group];
    },
  };
};


const initAppData = () => {
  return {
    team: "",
    knownTeams: ["sandbox", "global", ""],
    loadingCounter: 0,
    answeredIdsReset: undefined,
    answeredIds: [],
    knowTeams: [],

    admins: initData<UserPermissions[]>(),
    answeredQuestions: initData<[Question, Answer][]>(),
    friends: initData<Friend[]>(),
    matches: initData<UserMatch[]>(),
    openQuestions: initData<Question[]>(),
    ownQuestions: initData<Question[]>(),
    principal: initData<Principal>(),
    questionStats: initData<QuestionStats[]>(),
    teamAdmins: initData<User[]>(),
    teamMembers: initData<User[]>(),
    teamStats: initData<TeamStats>(),
    teams: initData<TeamUserInfo[]>(),
    user: initData<UserPermissions>(),
    users: initData<UserNotifications[]>(),

    chat: initDataBy<{ messages: Message[], status: ChatStatus }>(),
  }
}
let appData = initAppData();

export const getAppState = () => {
  return {
    user: mk<UserPermissions>(appData.user, backend.loadUser),
    users: mk<UserNotifications[]>(appData.users, backend.loadUsers),
    teams: mk<TeamUserInfo[]>(appData.teams, () => backend.loadTeams(appData.knowTeams)),
    friends: mk<Friend[]>(appData.friends, () => backend.loadFriends(appData.team)),
    chat: mkBy1<{ messages: Message[], status: ChatStatus }, string>(appData.chat, (user: string) => ((team: string) => backend.getMessages(team, user))),

    setTeam(key: string) {
      if (inBrowser()) {
        window.localStorage.setItem("team", key);
        if (appData.team !== key) {
          appData.knownTeams.push(key);
          appData = initAppData(); // TODO: only reset team specific data
          appData.team = key;
        }
      }
    },
    /**
     * Get team info or return null if selected team is not in teams, or teams are not loaded
     * 
     * @param orRedirect Redirect to `/select-team` if team doesn't exist
     *                         or to `/join/<team>` if current user is not a team member
     */
    getTeam(orRedirect: boolean = true): TeamUserInfo | null {
      let t = null;
      this.setTeam(inBrowser() ? window.localStorage.getItem("team") || "" : "");
      if (appData.teams.value.status === "ok") {
        t = appData.teams.value.data?.find((t) => t.key === appData.team) || null;
        if (!orRedirect) {
          // don't redirect
        } else if (!t) {
          navTo("/select-team");
        } else if (!t.permissions.isMember) {
          navTo("/join/" + t.key);
        };
      }
      return t;
    },
    getTeamKey(): string {
      this.setTeam(inBrowser() ? window.localStorage.getItem("team") || "" : "");
      return appData.team;
    },
    checkTeam() {
      const t = this.getTeam(false);
      if (t && !t.permissions.isMember) {
        navTo("/join/" + t.key)
      }
    },
    joinTeam(code: string, invitedBy: string | null): Promise<void> {
      return runNotify(backend.joinTeam(appData.team, code, invitedBy), "Welcome to the team!");
    },
    leaveTeam(user: string): Promise<void> {
      return runNotify(backend.leaveTeam(appData.team, user));
    },
    setTeamAdmin(user: string, admin: boolean): Promise<void> {
      return runNotify(backend.setTeamAdmin(appData.team, user, admin));
    },
    createTeam(team: string, name: string, about: string, logo: number[], listed: boolean, code: string): Promise<void> {
      return runNotify(backend.createTeam(team, name, about, logo, listed, code), "Welcome to the team!");
    },
    updateTeam(team: string, name: string, about: string, logo: number[], listed: boolean, code: string): Promise<void> {
      return runNotify(backend.updateTeam(team, name, about, logo, listed, code), "Welcome to the team!");
    },
    deleteQuestion(q: Question, hide: boolean) {
      return runNotify(backend.deleteQuestion(appData.team, q, hide), hide ? "Question removed" : "Question recovered")
    },
    deleteAnswers(confirm: string) {
      return runNotify(backend.deleteAnswers(appData.team, confirm), "Answers removed")
    },
    deleteUser(confirm: string) {
      return runNotify(backend.deleteUser(confirm), "User removed")
    },
    sendMessage(user: string, message: string) {
      return runNotify(backend.sendMessage(appData.team, user, message))
    },
    markMessageRead(user: string) {
      return runNotify(backend.markMessageRead(appData.team, user))
    },
  }
};

/// create get/set/load function for a data storer
const mk = <T>(store: Ref<NetworkData<T>>, action: () => FrontendEffect<T>, empty: T | null = null) => {
  const get = (): NetworkData<T> => store.value;
  const set = (next: NetworkData<T>): void => {
    const old = get();
    store.value = { status: "requested", errCount: 0, data: empty as T };
    setTimeout(() => store.value = combineNetworkData(old, next));
  };
  const load = (maxAgeS?: number): Promise<T> => {
    const old = get();
    if (shouldUpdate(old, maxAgeS)) {
      return runStore(old, action(), set)
    } else {
      return networkDataToPromise(old);
    };
  };
  /// like load but doesn't set the status to requested while loading
  const update = (maxAgeS?: number): Promise<T> => {
    const old = get();
    if (shouldUpdate(old, maxAgeS)) {
      return runStore(old, action(), set, true)
    } else {
      return networkDataToPromise(old);
    };
  };


  return { get, set, load, update };
};

/// create get/set/load function for a data storer with one parameter
const mk1 = <T, P1>(store: Ref<NetworkData<T>>, action: (p1: P1) => FrontendEffect<T>, empty: T | null = null) => {
  const get = (): NetworkData<T> => store.value;
  const set = (next: NetworkData<T>): void => {
    const old = get();
    store.value = { status: "requested", errCount: 0, data: empty as T };
    setTimeout(() => store.value = combineNetworkData(old, next));
  };
  const load = (p1: P1, maxAgeS?: number): Promise<T> => {
    const old = get();
    if (shouldUpdate(old, maxAgeS)) {
      return runStore(old, action(p1), set)
    } else {
      return networkDataToPromise(old);

    };
  };
  /// like load but doesn't set the status to requested while loading
  const update = (p1: P1, maxAgeS?: number): Promise<T> => {
    const old = get();
    if (shouldUpdate(old, maxAgeS)) {
      return runStore(old, action(p1), set, true)
    } else {
      return networkDataToPromise(old);
    };
  };

  return { get, set, load, update };
};
const mk2 = <T, P1, P2>(store: Ref<NetworkData<T>>, action: (p1: P1, p2: P2) => FrontendEffect<T>, empty: T | null = null) => {
  const get = (): NetworkData<T> => store.value;
  const set = (next: NetworkData<T>): void => {
    const old = get();
    store.value = { status: "requested", errCount: 0, data: empty as T };
    setTimeout(() => store.value = combineNetworkData(old, next));
  };
  const load = (p1: P1, p2: P2, maxAgeS?: number): Promise<T> => {
    const old = get();
    if (shouldUpdate(old, maxAgeS)) {
      return runStore(old, action(p1, p2), set)
    } else {
      return networkDataToPromise(old);

    };
  };
  /// like load but doesn't set the status to requested while loading
  const update = (p1: P1, p2: P2, maxAgeS?: number): Promise<T> => {
    const old = get();
    if (shouldUpdate(old, maxAgeS)) {
      return runStore(old, action(p1, p2), set, true)
    } else {
      return networkDataToPromise(old);
    };
  };

  return { get, set, load, update };
};


const mkBy1 = <T, P1>(store: DataBy<T>, action: (a: string) => (p1: P1) => FrontendEffect<T>, empty: T | null = null) => {
  const x: any = null;
  const _dummy = mk1<T, P1>(x, x);
  const all: { [group: string]: typeof _dummy } = {};
  return {
    get: (group: string) => {
      const ref = store.get(group);
      all[group] = all[group] ?? mk1<T, P1>(ref, action(group), empty);
      return all[group];
    }
  }
};


const mkBy2 = <T, P1, P2>(store: DataBy<T>, action: (a: string) => (p1: P1, p2: P2) => FrontendEffect<T>, empty: T | null = null) => {
  const x: any = null;
  const _dummy = mk2<T, P1, P2>(x, x, x);
  const all: { [group: string]: typeof _dummy } = {};
  return {
    get: (group: string) => {
      const ref = store.get(group);
      all[group] = all[group] ?? mk2<T, P1, P2>(ref, action(group), empty);
      return all[group];
    }
  }
};

// TODO: remove indirection by using navigateTo directly
export const navTo = (path: string) => {
  navigateTo(path);
  return;
}

export const useAppState = defineStore({
  id: 'app',
  state: (): AppState => defaultAppState(),
  actions: {
    setLoading(p: Promise<unknown>) {
      this.loadingCounter++;
      Promise.resolve(p).finally(() => this.loadingCounter--);
    },
    getLoading(): number {
      if (this.loadingCounter < 0) {
        console.error("loadingCounter was negative: ", this.loadingCounter);
        this.loadingCounter = 0;
      }
      return this.loadingCounter
    },
    getOpenQuestions(): NetworkData<Question[]> {
      return this.openQuestions as NetworkData<Question[]>; // TODO remove `as ...`
    },
    setOpenQuestions(qs: NetworkData<Question[]>, noAnswered: boolean = true): void {
      const { openQuestions } = storeToRefs(this);
      if (qs.status === 'ok') {
        const data = qs.data ?? [];
        qs.data = data.filter((x) => this.answeredIds.indexOf(x.id) < 0);

      }
      openQuestions.value = combineNetworkData(this.openQuestions, qs);
    },
    removeOpenQuestion(q: Question): void {
      const data = this.openQuestions as NetworkData<Question[]>
      this.answeredIds.push(q.id);
      if (this.answeredIdsReset) { clearTimeout(this.answeredIdsReset) }
      this.answeredIdsReset = setTimeout(() => { this.answeredIds = [] }, 10_000)
      if (data.data) {
        const i = data.data.findIndex((x) => x.id === q.id);
        if (1 >= 0) {
          //console.log("index of", q, "is", i, "in", this.openQuestions.data)
          data.data.splice(i, 1);
        }
      }
      this.setOpenQuestions({ status: "requested", errCount: 0 });
      setTimeout(() => this.setOpenQuestions(data));
    },
    loadOpenQuestions(maxAgeS?: number, msg?: string): Promise<Question[]> {

      if (shouldUpdate(this.openQuestions, maxAgeS)) {
        const old = this.getOpenQuestions();
        return runStoreNotify(old, backend.loadOpenQuestions(this.team), this.setOpenQuestions, msg)
      } else {
        return toPromise(this.getOpenQuestions())
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
        runStoreNotify(old, backend.getAnsweredQuestions(this.team), this.setAnsweredQuestions)
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
        runStoreNotify(old, backend.getOwnQuestions(this.team), this.setOwnQuestions);
      }
    },
    getPrincipal(): NetworkData<Principal> {
      return this.principal as NetworkData<Principal>;
    },
    setPrincipal(principal: NetworkData<Principal>): void {
      this.principal = combineNetworkData(this.principal, principal)
    },
    loadPrincipal(maxAgeS?: number) {
      if (shouldUpdate(this.principal, maxAgeS)) {
        return runStore(this.getPrincipal(), backend.getOwnPrincipal(), this.setPrincipal)
          .catch((e) => console.warn("couldn't loadPrincipal " + e));
      }
    },
    getUser(): NetworkData<UserPermissions> {
      return this.user as NetworkData<UserPermissions>;
    },
    setUser(user: NetworkData<UserPermissions>): void {
      const old = this.getUser();
      this.user = combineNetworkData(old, user)
    },
    loadUser(maxAgeS?: number, orRedirect: boolean = true): Promise<UserPermissions> {
      const old = this.getUser();
      if (shouldUpdate(old, maxAgeS)) {
        return runStore(old, backend.loadUser(false).pipe(Effect.mapError(
          (err) => {
            if (!orRedirect) return err;
            if (errors.is(err, "backend", "notRegistered")) {
              console.log("redirect to /register because user is not registered", err)
              navTo("/register");
            }
            else if (errors.is(err, "backend", "notLoggedIn")) {
              console.log("redirect to /login because user is not logged in", err)
              navTo("/login");
            }
            return err;
          }
        )), this.setUser)
      } else {
        return networkDataToPromise(this.getUser());
      }
    },
    getFriends() {
      return this.friends as NetworkData<Friend[]>; // TODO remove `as ...`
    },
    setFriends(friends: NetworkData<Friend[]>): void {
      const old = this.friends as NetworkData<Friend[]>
      this.friends = { status: "requested", errCount: 0, data: [] };
      setTimeout(() => this.friends = combineNetworkData(old, friends));
    },
    loadFriends(maxAgeS?: number) {
      if (shouldUpdate(this.friends, maxAgeS)) {
        runStore(this.friends, backend.loadFriends(this.team), this.setFriends)
          .catch(console.error);
      }
    },
    getMatches() {
      return this.matches as NetworkData<UserMatch[]>; // TODO remove `as ...`
    },
    setMatches(matches: NetworkData<UserMatch[]>): void {
      const old = this.matches as NetworkData<UserMatch[]>
      this.matches = combineNetworkData(old, matches)
    },
    loadMatches() {
      if (shouldUpdate(this.matches)) {
        runStore(this.matches, backend.loadMatches(this.team), this.setMatches)
          .catch(console.error);
      }
    },
    sendFriendRequest(username: string): Promise<void> {
      return runNotify(backend.sendFriendRequest(this.team, username), "Friend request send")
    },
    answerFriendRequest(username: string, accept: boolean): Promise<void> {
      return runNotify(backend.answerFriendRequest(this.team, username, accept), accept ? "Friend request accepted" : "Friend request rejected")
    },

    getTeams() {
      return this.teams as NetworkData<TeamUserInfo[]>; // TODO remove `as ...`
    },
    setTeams(teams: NetworkData<TeamUserInfo[]>): void {
      const old = this.teams as NetworkData<TeamUserInfo[]>
      this.teams = { status: "requested", errCount: 0, data: [] };
      setTimeout(() => this.teams = combineNetworkData(old, teams));
    },
    loadTeams(maxAgeS?: number, known?: string): Promise<TeamUserInfo[]> {
      if (known) {
        this.knownTeams.push(known);
        // remove duplicates
        this.knownTeams = [...new Set(this.knownTeams)];
      }
      if (shouldUpdate(this.teams, maxAgeS)) {
        return runStore(this.teams, backend.loadTeams(this.knownTeams), this.setTeams)
      } else {
        return networkDataToPromise(this.getTeams());
      }
    },
    setTeam(key: string) {
      if (inBrowser()) {
        window.localStorage.setItem("team", key);
        if (this.team !== key) {
          this.knownTeams.push(key);
          this.$reset(); // TODO: only reset team specific data
          this.team = key;
        }
      }
    },
    /**
     * Get team info or return null if selected team is not in teams, or teams are not loaded
     * 
     * @param orRedirect Redirect to `/select-team` if team doesn't exist
     *                         or to `/join/<team>` if current user is not a team member
     */
    getTeam(orRedirect: boolean = true): TeamUserInfo | null {
      let t = null;
      this.setTeam(inBrowser() ? window.localStorage.getItem("team") || "" : "");
      if (this.teams.status === "ok") {
        t = this.teams.data?.find((t) => t.key === this.team) || null;
        if (!orRedirect) {
          // don't redirect
        } else if (!t) {
          navTo("/select-team");
        } else if (!t.permissions.isMember) {
          navTo("/join/" + t.key);
        };
      }
      return t;
    },
    checkTeam() {
      const t = this.getTeam(false);
      if (t && !t.permissions.isMember) {
        navTo("/join/" + t.key)
      }
    },
    joinTeam(code: string, invitedBy: string | null): Promise<void> {
      return runNotify(backend.joinTeam(this.team, code, invitedBy), "Welcome to the team!");
    },
    leaveTeam(user: string): Promise<void> {
      return runNotify(backend.leaveTeam(this.team, user));
    },
    setTeamAdmin(user: string, admin: boolean): Promise<void> {
      return runNotify(backend.setTeamAdmin(this.team, user, admin));
    },
    createTeam(team: string, name: string, about: string, logo: number[], listed: boolean, code: string): Promise<void> {
      return runNotify(backend.createTeam(team, name, about, logo, listed, code), "Welcome to the team!");
    },
    updateTeam(team: string, name: string, about: string, logo: number[], listed: boolean, code: string): Promise<void> {
      return runNotify(backend.updateTeam(team, name, about, logo, listed, code), "Welcome to the team!");
    },
    deleteQuestion(q: Question, hide: boolean) {
      return runNotify(backend.deleteQuestion(this.team, q, hide), hide ? "Question removed" : "Question recovered")
    },
    deleteAnswers(confirm: string) {
      return runNotify(backend.deleteAnswers(this.team, confirm), "Answers removed")
    },
    deleteUser(confirm: string) {
      return runNotify(backend.deleteUser(confirm), "User removed")
    },

    getTeamStats() {
      return this.teamStats as NetworkData<TeamStats>; // TODO remove `as ...`
    },
    setTeamStats(teams: NetworkData<TeamStats>): void {
      const old = this.teamStats as NetworkData<TeamStats>
      this.teamStats = { status: "requested", errCount: 0, data: undefined };
      setTimeout(() => this.teamStats = combineNetworkData(old, teams));
    },
    loadTeamStats(maxAgeS?: number) {
      const old = this.getTeamStats();
      if (shouldUpdate(old, maxAgeS)) {
        runStore(old, backend.loadTeamStats(this.team), this.setTeamStats)
          .catch(console.error);
      }
    },

    getQuestionStats() {
      return this.questionStats as NetworkData<QuestionStats[]>; // TODO remove `as ...`
    },
    setQuestionStats(stats: NetworkData<QuestionStats[]>): void {
      const old = this.getQuestionStats();
      this.questionStats = { status: "requested", errCount: 0, data: undefined };
      setTimeout(() => this.questionStats = combineNetworkData(old, stats));
    },
    loadQuestionStats(maxAgeS?: number) {
      const old = this.getQuestionStats();
      if (shouldUpdate(old, maxAgeS)) {
        runStore(old, backend.loadQuestionStats(this.team), this.setQuestionStats)
          .catch(console.error);
      }
    },

    getTeamMembers() {
      return this.teamMembers as NetworkData<User[]>; // TODO remove `as ...`
    },
    setTeamMembers(members: NetworkData<User[]>): void {
      const old = this.getTeamMembers();
      this.teamMembers = { status: "requested", errCount: 0, data: [] };
      setTimeout(() => this.teamMembers = combineNetworkData(old, members));
    },
    loadTeamMembers(maxAgeS?: number) {
      if (shouldUpdate(this.teamMembers, maxAgeS)) {
        runStore(this.teamMembers, backend.loadTeamMembers(this.team), this.setTeamMembers)
          .catch(console.error);
      }
    },

    getTeamAdmins() {
      return this.teamAdmins as NetworkData<User[]>; // TODO remove `as ...`
    },
    setTeamAdmins(admins: NetworkData<User[]>): void {
      const old = this.getTeamAdmins();
      this.teamAdmins = { status: "requested", errCount: 0, data: [] };
      setTimeout(() => this.teamAdmins = combineNetworkData(old, admins));
    },
    loadTeamAdmins(maxAgeS?: number) {
      const current = this.getTeamAdmins();
      if (shouldUpdate(current, maxAgeS)) {
        runStore(current, backend.loadTeamAdmins(this.team), this.setTeamAdmins)
          .catch(console.error);
      }
    },

    getAdmins() {
      return this.admins as NetworkData<UserPermissions[]>; // TODO remove `as ...`
    },
    setAdmins(admins: NetworkData<UserPermissions[]>): void {
      const old = this.getAdmins();
      this.admins = { status: "requested", errCount: 0, data: [] };
      setTimeout(() => this.admins = combineNetworkData(old, admins));
    },
    loadAdmins(maxAgeS?: number) {
      if (shouldUpdate(this.getAdmins(), maxAgeS)) {
        runStore(this.getAdmins(), backend.loadAdmins(), this.setAdmins)
          .catch(console.error);
      }
    },
    getUsers() {
      return this.users as NetworkData<UserNotifications[]>; // TODO remove `as ...`
    },
    setUsers(users: NetworkData<UserNotifications[]>): void {
      const old = this.getUsers();
      this.users = { status: "requested", errCount: 0, data: [] };
      setTimeout(() => this.users = combineNetworkData(old, users));
    },
    loadUsers(maxAgeS?: number) {
      if (shouldUpdate(this.users, maxAgeS)) {
        runStore(this.users, backend.loadUsers(), this.setUsers)
          .catch(console.error);
      }
    },
  },
});

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
      if (maxAgeS === 0) return true;
      const limit = Date.now().valueOf() - ((maxAgeS || 30) * 1000);
      if (data.lastOK!.valueOf() < limit) {
        return true;
      }
      return false;
  }
}

const toPromise = <A>(data: NetworkData<A>): Promise<A> => {
  if (data.status === "ok") {
    return Promise.resolve(data.data!)
  } else if (data.status === "error") {
    return Promise.reject(data.err)
  } else {
    return Promise.reject(data.status)
  }
}

export const addNotification = (level: NotificationLevel, msg: string): void => {
  switch (level) {
    case "ok": console.log("notification (" + level + "): " + msg); break;
    case "warning": console.warn("notification (" + level + "): " + msg); break;
    case "error": console.warn("notification (" + level + "): " + msg); break;
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

export const invitePath = (team: string, invite: string, user: string | null): string => {
  const params = user ? new URLSearchParams({ invite, by: user }) : new URLSearchParams({ invite });
  return "/join/" + team + "?" + params.toString();
}

export const invite = (personal: boolean): string | undefined => {
  const app = useAppState();
  const team = app.getTeam();
  if (!team) return undefined;
  const user = app.getUser().data?.user.username ?? null;
  let code = app.getTeam()?.invite;
  let path = "";

  if (personal) {
    code = team.userInvite
    if (!user || !code[0]) return undefined;
    path = invitePath(app.getTeam()?.key || "", code[0], user);
  } else {
    if (!code?.length) return undefined;
    path = invitePath(app.getTeam()?.key || "", code[0], null);
  }

  return document.location.origin + path;
}

export const copyInvite = (personal: boolean = false) => {
  const link = invite(personal);
  if (link) {
    navigator.clipboard.writeText(link);
    addNotification('ok', "Invite link copied.")
  } else if (personal) {
    addNotification('error', "Couldn't generate invite link.")
  } else {
    addNotification('error', "Couldn't generate invite link.\nDo you have admin permissions?")
  }
}

export const copyPersonalInvite = () => {
  return copyInvite(true);
}

