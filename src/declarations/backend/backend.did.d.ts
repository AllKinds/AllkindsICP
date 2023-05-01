import type { ActorMethod } from '@dfinity/agent';
import type { Principal } from '@dfinity/principal';

export type FriendStatus = { Approved: null } | { Waiting: null } | { Requested: null };
export interface FriendlyUserMatch {
	status: FriendStatus;
	principal: Principal;
	connect: [] | [string];
	about: [] | [string];
	username: string;
	cohesion: bigint;
	answered: Array<[Question, boolean]>;
	picture: [] | [Uint8Array | number[]];
	gender: [] | [Gender];
	birth: [] | [bigint];
	uncommon: Array<Question>;
}
export type Gender = { Male: null } | { Female: null } | { Other: null } | { Queer: null };
export type Hash = number;
export interface MatchingFilter {
	cohesion: bigint;
	ageRange: [bigint, bigint];
	gender: [] | [Gender];
}
export interface Question {
	created: bigint;
	creater: Principal;
	question: string;
	hash: Hash;
	color: string;
	points: bigint;
}
export interface Question__1 {
	created: bigint;
	creater: Principal;
	question: string;
	hash: Hash;
	color: string;
	points: bigint;
}
export type Result = { ok: null } | { err: string };
export type Result_1 = { ok: User } | { err: string };
export type Result_2 = { ok: Array<FriendlyUserMatch> } | { err: string };
export type Result_3 = { ok: Array<Question__1> } | { err: string };
export type Result_4 = { ok: UserMatch } | { err: string };
export interface User {
	created: bigint;
	connect: [[] | [string], boolean];
	about: [[] | [string], boolean];
	username: string;
	picture: [[] | [Uint8Array | number[]], boolean];
	gender: [[] | [Gender], boolean];
	birth: [[] | [bigint], boolean];
	points: bigint;
}
export interface UserMatch {
	principal: Principal;
	connect: [] | [string];
	about: [] | [string];
	username: string;
	cohesion: bigint;
	answered: Array<[Question, boolean]>;
	picture: [] | [Uint8Array | number[]];
	gender: [] | [Gender];
	birth: [] | [bigint];
	uncommon: Array<Question>;
}
export interface _SERVICE {
	answerFriendRequest: ActorMethod<[Principal, boolean], Result>;
	createQuestion: ActorMethod<[string, string], Result>;
	createUser: ActorMethod<[string], Result>;
	findMatch: ActorMethod<[MatchingFilter], Result_4>;
	getAnsweredQuestions: ActorMethod<[], Result_3>;
	getAskableQuestions: ActorMethod<[bigint], Result_3>;
	getFriends: ActorMethod<[], Result_2>;
	getUser: ActorMethod<[], Result_1>;
	sendFriendRequest: ActorMethod<[Principal], Result>;
	submitAnswer: ActorMethod<[Hash, boolean, bigint], Result>;
	submitSkip: ActorMethod<[Hash], Result>;
	updateProfile: ActorMethod<[User], Result>;
	whoami: ActorMethod<[], Principal>;
}
