import type { ActorMethod } from '@dfinity/agent';
import type { Principal } from '@dfinity/principal';

export type AnswerKind = { Bool: boolean };
export type Color = { Default: null };
export type Gender = { Male: null } | { Female: null } | { Other: null } | { Queer: null };
export type Hash = number;
export type LikeKind = { Like: bigint } | { Dislike: bigint };
export interface MatchingFilter {
	cohesion: bigint;
	minAge: bigint;
	gender: [] | [Gender];
	maxAge: bigint;
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
export type Result_2 = { ok: Array<Question> } | { err: string };
export type Result_3 = { ok: Array<User> } | { err: string };
export interface User {
	created: bigint;
	connect: [[] | [string], boolean];
	about: [[] | [string], boolean];
	username: string;
	gender: [[] | [Gender], boolean];
	birth: [[] | [bigint], boolean];
	points: bigint;
}
export interface _SERVICE {
	createQuestion: ActorMethod<[string], Result>;
	createUser: ActorMethod<[string], Result>;
	findMatches: ActorMethod<[MatchingFilter], Result_3>;
	getAnsweredQuestions: ActorMethod<[bigint], Result_2>;
	getAskableQuestions: ActorMethod<[bigint], Result_2>;
	getUser: ActorMethod<[], Result_1>;
	submitAnswer: ActorMethod<[Hash, AnswerKind], Result>;
	submitLike: ActorMethod<[Hash, LikeKind], Result>;
	submitSkip: ActorMethod<[Hash], Result>;
	updateProfile: ActorMethod<[User], Result>;
}
