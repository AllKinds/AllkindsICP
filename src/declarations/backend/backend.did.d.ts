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
export type Result = { 'ok' : null } |
  { 'err' : Error };
export type ResultAnswer = { 'ok' : Answer } |
  { 'err' : Error };
export type ResultQuestion = { 'ok' : Question__1 } |
  { 'err' : Error };
export type ResultSkip = { 'ok' : Skip } |
  { 'err' : Error };
export type ResultUser = { 'ok' : User } |
  { 'err' : Error };
export type ResultUserMatch = { 'ok' : UserMatch } |
  { 'err' : Error };
export type ResultUserMatches = { 'ok' : Array<UserMatch> } |
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
  'answerFriendRequest' : ActorMethod<[string, boolean], Result>,
  'createQuestion' : ActorMethod<[string, string], ResultQuestion>,
  'createUser' : ActorMethod<[string], ResultUser>,
  'findMatch' : ActorMethod<
    [number, number, [] | [Gender], number, number],
    ResultUserMatch
  >,
  'getAnsweredQuestions' : ActorMethod<[bigint], Array<[Question__1, Answer]>>,
  'getAskableQuestions' : ActorMethod<[bigint], Array<Question__1>>,
  'getFriends' : ActorMethod<[], ResultUserMatches>,
  'getUser' : ActorMethod<[], ResultUser>,
  'sendFriendRequest' : ActorMethod<[string], Result>,
  'submitAnswer' : ActorMethod<[bigint, boolean, bigint], ResultAnswer>,
  'submitSkip' : ActorMethod<[bigint], ResultSkip>,
  'updateProfile' : ActorMethod<[User], ResultUser>,
  'whoami' : ActorMethod<[], Principal>,
}
