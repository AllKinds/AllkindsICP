import type { Principal } from '@dfinity/principal';
import type { ActorMethod } from '@dfinity/agent';

export interface AdminPermissions {
  'createTeam' : boolean,
  'suspendUser' : boolean,
}
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
  { 'questionNotFound' : null } |
  { 'tooLong' : null } |
  { 'insufficientFunds' : null } |
  { 'notEnoughAnswers' : null } |
  { 'tooShort' : null } |
  { 'friendAlreadyConnected' : null } |
  { 'nameNotAvailable' : null } |
  { 'invalidInvite' : null } |
  { 'teamNotFound' : null } |
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
export interface Permissions { 'isMember' : boolean, 'isAdmin' : boolean }
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
export interface QuestionStats {
  'no' : bigint,
  'yes' : bigint,
  'question' : Question__1,
  'answers' : bigint,
  'boosts' : bigint,
  'skips' : bigint,
}
export interface Question__1 {
  'id' : QuestionID__1,
  'created' : Time__1,
  'creator' : [] | [string],
  'question' : string,
  'color' : string,
  'points' : bigint,
}
export interface Question__2 {
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
export type ResultQuestionStats = { 'ok' : Array<QuestionStats> } |
  { 'err' : Error };
export type ResultSkip = { 'ok' : Skip } |
  { 'err' : Error };
export type ResultTeam = { 'ok' : TeamInfo__1 } |
  { 'err' : Error };
export type ResultTeamStats = { 'ok' : TeamStats } |
  { 'err' : Error };
export type ResultTeams = { 'ok' : Array<TeamUserInfo> } |
  { 'err' : Error };
export type ResultUser = { 'ok' : User } |
  { 'err' : Error };
export type ResultUserMatches = { 'ok' : Array<UserMatch> } |
  { 'err' : Error };
export type ResultUsers = { 'ok' : Array<User> } |
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
  'hidden' : boolean,
  'showCreator' : boolean,
  'points' : bigint,
}
export interface TeamInfo {
  'about' : string,
  'logo' : Uint8Array | number[],
  'name' : string,
  'listed' : boolean,
}
export interface TeamInfo__1 {
  'about' : string,
  'logo' : Uint8Array | number[],
  'name' : string,
  'listed' : boolean,
}
export interface TeamStats {
  'answers' : bigint,
  'connections' : bigint,
  'users' : bigint,
  'questions' : bigint,
}
export interface TeamUserInfo {
  'key' : string,
  'permissions' : Permissions,
  'info' : TeamInfo,
  'invite' : [] | [string],
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
  'answered' : Array<[Question__2, AnswerDiff]>,
  'user' : UserInfo,
  'uncommon' : Array<Question__2>,
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
  'createTeam' : ActorMethod<[string, string, TeamInfo__1], ResultTeam>,
  'createTestData' : ActorMethod<[string, bigint, bigint], bigint>,
  'createUser' : ActorMethod<[string, string], ResultUser>,
  'deleteQuestion' : ActorMethod<[string, Question], Result>,
  'getAnsweredQuestions' : ActorMethod<
    [string, bigint],
    Array<[Question, Answer]>
  >,
  'getFriends' : ActorMethod<[string], ResultFriends>,
  'getMatches' : ActorMethod<[string], ResultUserMatches>,
  'getOwnQuestions' : ActorMethod<[string, bigint], Array<Question>>,
  'getPermissions' : ActorMethod<
    [],
    { 'permissions' : AdminPermissions, 'principal' : Principal }
  >,
  'getQuestionStats' : ActorMethod<[string, bigint], ResultQuestionStats>,
  'getTeamMembers' : ActorMethod<[string], ResultUsers>,
  'getTeamStats' : ActorMethod<[string], ResultTeamStats>,
  'getUnansweredQuestions' : ActorMethod<[string, bigint], Array<Question>>,
  'getUser' : ActorMethod<[], ResultUser>,
  'joinTeam' : ActorMethod<[string, string], ResultTeam>,
  'listTeams' : ActorMethod<[Array<string>], ResultTeams>,
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
