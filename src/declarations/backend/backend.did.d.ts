import type { ActorMethod } from '@dfinity/agent';
import type { Principal } from '@dfinity/principal';

export type AnswerKind = { Bool: boolean };
export type Color = { Default: null };
export interface Friend {
	status: [] | [FriendStatus];
	account: Principal;
}
export type FriendStatus = { Approved: null } | { Waiting: null } | { Requested: null };
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
export type Result_1 = { ok: string } | { err: string };
export type Result_2 = { ok: User } | { err: string };
export type Result_3 = { ok: Array<Friend> } | { err: string };
export type Result_4 = { ok: Array<Question> } | { err: string };
export type Result_5 = { ok: UserMatch } | { err: string };
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
export type WeightKind = { Like: bigint } | { Dislike: bigint };
export interface _SERVICE {
	createQuestion: ActorMethod<[string], Result>;
	createUser: ActorMethod<[string], Result>;
	findMatch: ActorMethod<[MatchingFilter], Result_5>;
	getAnsweredQuestions: ActorMethod<[[] | [bigint]], Result_4>;
	getAskableQuestions: ActorMethod<[bigint], Result_4>;
	getFriends: ActorMethod<[], Result_3>;
	getUser: ActorMethod<[], Result_2>;
	sendFriendRequest: ActorMethod<[Principal], Result_1>;
	submitAnswer: ActorMethod<[Hash, AnswerKind], Result>;
	submitSkip: ActorMethod<[Hash], Result>;
	submitWeight: ActorMethod<[Hash, WeightKind], Result>;
	updateProfile: ActorMethod<[User], Result>;
}
