import type { Principal } from '@dfinity/principal';
import type { ActorMethod } from '@dfinity/agent';

export interface Answer {
  'weight' : bigint,
  'created' : Time__1,
  'question' : bigint,
  'answer' : boolean,
}
export interface AnswerDiff {
  'weight' : bigint,
  'question' : bigint,
  'sameAnswer' : boolean,
}
export type Error = { 'notInTeam' : null } |
  { 'notLoggedIn' : null } |
  { 'validationError' : null } |
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
export type Friend = [UserMatch, FriendStatus];
export type FriendStatus = { 'requestReceived' : null } |
  { 'connected' : null } |
  { 'rejectionSend' : null } |
  { 'rejectionReceived' : null } |
  { 'requestSend' : null };
export interface Question {
  'id' : QuestionID__1,
  'created' : Time__1,
  'creator' : [] | [string],
  'question' : string,
  'color' : string,
  'points' : bigint,
}
export type QuestionID = bigint;
export type QuestionID__1 = bigint;
export interface Question__1 {
  'id' : QuestionID__1,
  'created' : Time__1,
  'creator' : [] | [string],
  'question' : string,
  'color' : string,
  'points' : bigint,
}
export type Result = { 'ok' : null } |
  { 'err' : Error };
export type ResultAnswer = { 'ok' : Answer } |
  { 'err' : Error };
export type ResultFriends = { 'ok' : Array<Friend> } |
  { 'err' : Error };
export type ResultQuestion = { 'ok' : Question } |
  { 'err' : Error };
export type ResultSkip = { 'ok' : Skip } |
  { 'err' : Error };
export type ResultUser = { 'ok' : User } |
  { 'err' : Error };
export type ResultUserMatches = { 'ok' : Array<UserMatch> } |
  { 'err' : Error };
export interface Skip {
  'question' : bigint,
  'reason' : { 'flag' : null } |
    { 'skip' : null },
}
export interface StableQuestion {
  'id' : QuestionID__1,
  'created' : Time__1,
  'creator' : Principal,
  'question' : string,
  'color' : string,
  'points' : bigint,
}
export type Time = bigint;
export type Time__1 = bigint;
export interface User {
  'created' : Time,
  'contact' : string,
  'about' : string,
  'username' : string,
  'displayName' : string,
  'picture' : [] | [Uint8Array | number[]],
  'stats' : UserStats,
}
export interface UserInfo {
  'contact' : string,
  'about' : string,
  'username' : string,
  'displayName' : string,
  'picture' : [] | [Uint8Array | number[]],
}
export interface UserMatch {
  'cohesion' : number,
  'answered' : Array<[Question__1, AnswerDiff]>,
  'user' : UserInfo,
  'uncommon' : Array<Question__1>,
}
export interface UserStats {
  'asked' : bigint,
  'answered' : bigint,
  'boosts' : bigint,
  'points' : bigint,
}
export interface _SERVICE {
  'airdrop' : ActorMethod<[string, bigint], Result>,
  'answerFriendRequest' : ActorMethod<[string, string, boolean], Result>,
  'backupAnswers' : ActorMethod<
    [string, bigint, bigint],
    Array<StableQuestion>
  >,
  'backupConnections' : ActorMethod<
    [string, bigint, bigint],
    Array<[Principal, Principal, FriendStatus]>
  >,
  'backupQuestions' : ActorMethod<
    [string, bigint, bigint],
    Array<StableQuestion>
  >,
  'backupUsers' : ActorMethod<[bigint, bigint], Array<[Principal, User]>>,
  'createQuestion' : ActorMethod<[string, string, string], ResultQuestion>,
  'createTestData' : ActorMethod<[string, bigint, bigint], bigint>,
  'createUser' : ActorMethod<[string, string], ResultUser>,
  'getAnsweredQuestions' : ActorMethod<
    [string, bigint],
    Array<[Question, Answer]>
  >,
  'getFriends' : ActorMethod<[string], ResultFriends>,
  'getMatches' : ActorMethod<[string], ResultUserMatches>,
  'getOwnQuestions' : ActorMethod<[string, bigint], Array<Question>>,
  'getUnansweredQuestions' : ActorMethod<[string, bigint], Array<Question>>,
  'getUser' : ActorMethod<[], ResultUser>,
  'selfDestruct' : ActorMethod<[string], undefined>,
  'sendFriendRequest' : ActorMethod<[string, string], Result>,
  'submitAnswer' : ActorMethod<
    [string, QuestionID, boolean, bigint],
    ResultAnswer
  >,
  'submitSkip' : ActorMethod<[string, bigint], ResultSkip>,
  'updateProfile' : ActorMethod<[User], ResultUser>,
  'whoami' : ActorMethod<[], Principal>,
}
