import type { ActorMethod } from '@dfinity/agent';
import type { Principal } from '@dfinity/principal';

export type Color = { Default: null };
export type FriendStatus = { Approved: null } | { Waiting: null } | { Requested: null };
export interface FriendlyUserMatch {
	status: FriendStatus;
	principal: Principal;
	connect: [] | [string];
	about: [] | [string];
	username: string;
	cohesion: bigint;
	gender: [] | [Gender];
	birth: [] | [bigint];
	answeredQuestions: Array<Question>;
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
	color: [] | [Color];
	points: bigint;
}
export type Result = { ok: null } | { err: string };
export type Result_1 = { ok: User } | { err: string };
export type Result_2 = { ok: Array<FriendlyUserMatch> } | { err: string };
export type Result_3 = { ok: Array<Question> } | { err: string };
export type Result_4 = { ok: UserMatch } | { err: string };
export interface User {
	created: bigint;
	connect: [[] | [string], boolean];
	about: [[] | [string], boolean];
	username: string;
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
	gender: [] | [Gender];
	birth: [] | [bigint];
	answeredQuestions: Array<Question>;
}
export interface _SERVICE {
	answerFriendRequest: ActorMethod<[Principal, boolean], Result>;
	createQuestion: ActorMethod<[string], Result>;
	createUser: ActorMethod<[string], Result>;
	findMatch: ActorMethod<[MatchingFilter], Result_4>;
	getAnsweredQuestions: ActorMethod<[[] | [bigint]], Result_3>;
	getAskableQuestions: ActorMethod<[bigint], Result_3>;
	getFriends: ActorMethod<[], Result_2>;
	getUser: ActorMethod<[], Result_1>;
	sendFriendRequest: ActorMethod<[Principal], Result>;
	submitAnswer: ActorMethod<[Hash, boolean, bigint], Result>;
	submitSkip: ActorMethod<[Hash], Result>;
	updateProfile: ActorMethod<[User], Result>;
}
