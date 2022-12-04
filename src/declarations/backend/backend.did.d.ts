import type { ActorMethod } from '@dfinity/agent';
import type { Principal } from '@dfinity/principal';

export type AnswerKind = { Bool: boolean };
export type Color = { Default: null };
export type Gender = { Male: null } | { Female: null } | { Other: null } | { Queer: null };
export type Hash = number;
export type LikeKind = { Like: bigint } | { Dislike: bigint };
export interface Question {
	created: bigint;
	creater: Principal;
	question: string;
	hash: Hash;
	color: [] | [Color];
}
export type Result = { ok: null } | { err: string };
export type Result_1 = { ok: User } | { err: string };
export type Result_2 = { ok: Array<Question> } | { err: string };
export interface User {
	created: bigint;
	connect: [[] | [string], boolean];
	about: [[] | [string], boolean];
	username: string;
	gender: [[] | [Gender], boolean];
	birth: [[] | [bigint], boolean];
}
export interface _SERVICE {
	createQuestion: ActorMethod<[string], Result>;
	createUser: ActorMethod<[string], Result>;
	getAskableQuestions: ActorMethod<[], Result_2>;
	getUser: ActorMethod<[], Result_1>;
	submitAnswer: ActorMethod<[Hash, AnswerKind], Result>;
	submitLike: ActorMethod<[Hash, LikeKind], Result>;
	submitSkip: ActorMethod<[Hash], Result>;
	updateProfile: ActorMethod<[User], Result>;
}
