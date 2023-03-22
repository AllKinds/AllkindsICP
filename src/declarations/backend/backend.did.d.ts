import type { Principal } from '@dfinity/principal';
import type { ActorMethod } from '@dfinity/agent';

export type AnswerKind = { 'Bool' : boolean };
export type Color = { 'Default' : null };
export type Gender = { 'Male' : null } |
  { 'Female' : null } |
  { 'Other' : null } |
  { 'Queer' : null };
export type Hash = number;
export interface MatchingFilter {
  'cohesion' : bigint,
  'ageRange' : [bigint, bigint],
  'gender' : [] | [Gender],
}
export interface Question {
  'created' : bigint,
  'creater' : Principal,
  'question' : string,
  'hash' : Hash,
  'color' : [] | [Color],
  'points' : bigint,
}
export type Result = { 'ok' : null } |
  { 'err' : string };
export type Result_1 = { 'ok' : User } |
  { 'err' : string };
export type Result_2 = { 'ok' : Array<Question> } |
  { 'err' : string };
export type Result_3 = { 'ok' : Array<UserMatch> } |
  { 'err' : string };
export interface User {
  'created' : bigint,
  'connect' : [[] | [string], boolean],
  'about' : [[] | [string], boolean],
  'username' : string,
  'gender' : [[] | [Gender], boolean],
  'birth' : [[] | [bigint], boolean],
  'points' : bigint,
}
export interface UserMatch {
  'connect' : [] | [string],
  'about' : [] | [string],
  'username' : string,
  'score' : number,
  'gender' : [] | [Gender],
  'birth' : [] | [bigint],
}
export type WeightKind = { 'Like' : bigint } |
  { 'Dislike' : bigint };
export interface _SERVICE {
  'createQuestion' : ActorMethod<[string], Result>,
  'createUser' : ActorMethod<[string], Result>,
  'findMatches' : ActorMethod<[MatchingFilter], Result_3>,
  'getAnsweredQuestions' : ActorMethod<[bigint], Result_2>,
  'getAskableQuestions' : ActorMethod<[bigint], Result_2>,
  'getUser' : ActorMethod<[], Result_1>,
  'submitAnswer' : ActorMethod<[Hash, AnswerKind], Result>,
  'submitSkip' : ActorMethod<[Hash], Result>,
  'submitWeight' : ActorMethod<[Hash, WeightKind], Result>,
  'updateProfile' : ActorMethod<[User], Result>,
}
