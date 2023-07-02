import type { Principal } from '@dfinity/principal';
import type { ActorMethod } from '@dfinity/agent';

export interface Answer {
  'weight' : bigint,
  'question' : bigint,
  'answer' : boolean,
}
export interface AnswerDiff {
  'weight' : bigint,
  'question' : bigint,
  'sameAnswer' : boolean,
}
export type Error = { 'validationError' : null } |
  { 'userNotFound' : null } |
  { 'tooLong' : null } |
  { 'insufficientFunds' : null } |
  { 'notEnoughAnswers' : null } |
  { 'tooShort' : null } |
  { 'friendAlreadyConnected' : null } |
  { 'nameNotAvailable' : null } |
  { 'alreadyRegistered' : null } |
  { 'friendRequestAlreadySend' : null } |
  { 'notRegistered' : null } |
  { 'invalidColor' : null };
export type Gender = { 'Male' : null } |
  { 'Female' : null } |
  { 'Other' : null } |
  { 'Queer' : null };
export type IsPublic = boolean;
export interface MatchingFilter { 'cohesion' : number, 'users' : UserFilter }
export interface Question {
  'id' : bigint,
  'created' : Time__1,
  'creator' : Principal,
  'question' : string,
  'color' : string,
  'points' : bigint,
}
export interface Question__1 {
  'id' : bigint,
  'created' : Time__1,
  'creator' : Principal,
  'question' : string,
  'color' : string,
  'points' : bigint,
}
export type Result = { 'ok' : User } |
  { 'err' : Error };
export type Result_1 = { 'ok' : Skip } |
  { 'err' : Error };
export type Result_2 = { 'ok' : Answer } |
  { 'err' : Error };
export type Result_3 = { 'ok' : null } |
  { 'err' : Error };
export type Result_4 = { 'ok' : Array<UserMatch> } |
  { 'err' : Error };
export type Result_5 = { 'ok' : UserMatch } |
  { 'err' : Error };
export type Result_6 = { 'ok' : Question__1 } |
  { 'err' : Error };
export interface Skip {
  'question' : bigint,
  'reason' : { 'flag' : null } |
    { 'skip' : null },
}
export interface Social { 'network' : SocialNetwork, 'handle' : string }
export type SocialNetwork = { 'mastodon' : null } |
  { 'twitter' : null } |
  { 'email' : null } |
  { 'distrikt' : null } |
  { 'phone' : null } |
  { 'dscvr' : null };
export type Time = bigint;
export type Time__1 = bigint;
export interface User {
  'created' : Time,
  'about' : [[] | [string], IsPublic],
  'username' : string,
  'socials' : Array<[Social, IsPublic]>,
  'picture' : [[] | [Uint8Array | number[]], IsPublic],
  'gender' : [[] | [Gender], IsPublic],
  'birth' : [[] | [Time], IsPublic],
  'points' : bigint,
}
export interface UserFilter {
  'maxBirth' : Time,
  'gender' : [] | [Gender],
  'minBirth' : Time,
}
export interface UserInfo {
  'about' : [] | [string],
  'username' : string,
  'socials' : Array<Social>,
  'picture' : [] | [Uint8Array | number[]],
  'gender' : [] | [Gender],
  'birth' : [] | [Time],
}
export interface UserMatch {
  'cohesion' : number,
  'answered' : Array<[Question, AnswerDiff]>,
  'user' : UserInfo,
  'uncommon' : Array<Question>,
}
export interface _SERVICE {
  'answerFriendRequest' : ActorMethod<[string, boolean], Result_3>,
  'createQuestion' : ActorMethod<[string, string], Result_6>,
  'createUser' : ActorMethod<[string], Result>,
  'findMatch' : ActorMethod<[MatchingFilter], Result_5>,
  'getAnsweredQuestions' : ActorMethod<[bigint], Array<[Question__1, Answer]>>,
  'getAskableQuestions' : ActorMethod<[bigint], Array<Question__1>>,
  'getFriends' : ActorMethod<[], Result_4>,
  'getUser' : ActorMethod<[], Result>,
  'sendFriendRequest' : ActorMethod<[string], Result_3>,
  'submitAnswer' : ActorMethod<[bigint, boolean, bigint], Result_2>,
  'submitSkip' : ActorMethod<[bigint], Result_1>,
  'updateProfile' : ActorMethod<[User], Result>,
  'whoami' : ActorMethod<[], Principal>,
}
