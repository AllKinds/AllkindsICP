import type { Principal as PrincipalInternal} from "@dfinity/principal";
export type Principal = Omit<Principal, "_arr">;
import type { ActorMethod } from '@dfinity/agent';
import type { IDL } from '@dfinity/candid';

export interface AdminPermissions {
  'becomeTeamMember' : boolean,
  'createTeam' : boolean,
  'createBackup' : boolean,
  'listAllTeams' : boolean,
  'suspendUser' : boolean,
  'editUser' : boolean,
  'restoreBackup' : boolean,
  'becomeTeamAdmin' : boolean,
}
export interface AdminPermissions__1 {
  'becomeTeamMember' : boolean,
  'createTeam' : boolean,
  'createBackup' : boolean,
  'listAllTeams' : boolean,
  'suspendUser' : boolean,
  'editUser' : boolean,
  'restoreBackup' : boolean,
  'becomeTeamAdmin' : boolean,
}
export interface Answer {
  'weight' : bigint,
  'created' : Time,
  'question' : bigint,
  'answer' : boolean,
}
export interface AnswerDiff {
  'weight' : bigint,
  'question' : bigint,
  'sameAnswer' : boolean,
}
export interface ChatStatus { 'unread' : bigint }
export type Error = { 'notInTeam' : null } |
  { 'notLoggedIn' : null } |
  { 'validationError' : null } |
  { 'userNotFound' : null } |
  { 'questionNotFound' : null } |
  { 'tooLong' : null } |
  { 'insufficientFunds' : null } |
  { 'permissionDenied' : null } |
  { 'notEnoughAnswers' : null } |
  { 'tooShort' : null } |
  { 'friendAlreadyConnected' : null } |
  { 'notAFriend' : null } |
  { 'nameNotAvailable' : null } |
  { 'invalidInvite' : null } |
  { 'teamNotFound' : null } |
  { 'alreadyRegistered' : null } |
  { 'friendRequestAlreadySend' : null } |
  { 'notRegistered' : Principal } |
  { 'invalidColor' : null };
export type Error__1 = { 'notInTeam' : null } |
  { 'notLoggedIn' : null } |
  { 'validationError' : null } |
  { 'userNotFound' : null } |
  { 'questionNotFound' : null } |
  { 'tooLong' : null } |
  { 'insufficientFunds' : null } |
  { 'permissionDenied' : null } |
  { 'notEnoughAnswers' : null } |
  { 'tooShort' : null } |
  { 'friendAlreadyConnected' : null } |
  { 'notAFriend' : null } |
  { 'nameNotAvailable' : null } |
  { 'invalidInvite' : null } |
  { 'teamNotFound' : null } |
  { 'alreadyRegistered' : null } |
  { 'friendRequestAlreadySend' : null } |
  { 'notRegistered' : Principal } |
  { 'invalidColor' : null };
export type Friend = [UserMatch, FriendStatus];
export type FriendStatus = { 'requestReceived' : null } |
  { 'connected' : null } |
  { 'rejectionSend' : null } |
  { 'rejectionReceived' : null } |
  { 'requestSend' : null };
export interface Message {
  'content' : string,
  'time' : Time,
  'sender' : boolean,
}
export interface Message__1 {
  'content' : string,
  'time' : Time,
  'sender' : boolean,
}
export interface Notification {
  'team' : Array<string>,
  'event' : {
      'chat' : { 'user' : string, 'latest' : Message, 'unread' : bigint }
    } |
    { 'rewards' : bigint } |
    { 'newQuestions' : bigint } |
    { 'friendRequests' : bigint },
}
export interface Permissions { 'isMember' : boolean, 'isAdmin' : boolean }
export interface Question {
  'id' : QuestionID__1,
  'created' : Time,
  'creator' : [] | [string],
  'deleted' : boolean,
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
  'created' : Time,
  'creator' : [] | [string],
  'deleted' : boolean,
  'question' : string,
  'color' : string,
  'points' : bigint,
}
export interface Question__2 {
  'id' : QuestionID__1,
  'created' : Time,
  'creator' : [] | [string],
  'deleted' : boolean,
  'question' : string,
  'color' : string,
  'points' : bigint,
}
export type Result = { 'ok' : string } |
  { 'err' : Error };
export type ResultAnswer = { 'ok' : Answer } |
  { 'err' : Error };
export type ResultFriends = { 'ok' : Array<Friend> } |
  { 'err' : Error };
export type ResultMessages = {
    'ok' : { 'status' : ChatStatus, 'messages' : Array<Message__1> }
  } |
  { 'err' : Error };
export type ResultNat = { 'ok' : bigint } |
  { 'err' : Error };
export type ResultQuestion = { 'ok' : Question } |
  { 'err' : Error };
export type ResultQuestionStats = { 'ok' : Array<QuestionStats> } |
  { 'err' : Error };
export type ResultSkip = { 'ok' : Skip } |
  { 'err' : Error };
export type ResultTeam = { 'ok' : TeamInfo } |
  { 'err' : Error };
export type ResultTeamStats = { 'ok' : TeamStats } |
  { 'err' : Error };
export type ResultTeams = { 'ok' : Array<TeamUserInfo> } |
  { 'err' : Error };
export type ResultUser = { 'ok' : UserPermissions } |
  { 'err' : Error };
export type ResultUserMatches = { 'ok' : Array<UserMatch> } |
  { 'err' : Error };
export type ResultUserPermissions = { 'ok' : Array<UserPermissions> } |
  { 'err' : Error };
export type ResultUsers = { 'ok' : Array<User> } |
  { 'err' : Error };
export type ResultUsersNotifications = { 'ok' : Array<UserNotifications> } |
  { 'err' : Error };
export type ResultVoid = { 'ok' : null } |
  { 'err' : Error };
export interface Skip {
  'question' : bigint,
  'reason' : { 'flag' : null } |
    { 'skip' : null },
}
export interface StableQuestion {
  'id' : QuestionID__1,
  'created' : Time,
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
  'info' : TeamInfo__1,
  'userInvite' : [] | [string],
  'invite' : [] | [string],
}
export type Time = bigint;
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
  'errors' : Array<Error__1>,
  'uncommon' : Array<Question__2>,
}
export interface UserNotifications {
  'notifications' : Array<Notification>,
  'user' : User__1,
}
export interface UserPermissions {
  'permissions' : AdminPermissions,
  'notifications' : Array<Notification>,
  'user' : User__1,
}
export interface UserStats {
  'asked' : bigint,
  'answered' : bigint,
  'boosts' : bigint,
  'points' : bigint,
}
export interface User__1 {
  'created' : Time,
  'contact' : string,
  'about' : string,
  'username' : string,
  'displayName' : string,
  'picture' : [] | [Uint8Array | number[]],
  'stats' : UserStats,
}
export interface _SERVICE {
  'airdrop' : ActorMethod<[string, bigint], ResultVoid>,
  'answerFriendRequest' : ActorMethod<[string, string, boolean], ResultVoid>,
  'backupConnections' : ActorMethod<
    [string, bigint, bigint],
    Array<[Principal, Principal, FriendStatus]>
  >,
  'backupQuestions' : ActorMethod<
    [string, bigint, bigint],
    Array<StableQuestion>
  >,
  'backupUsers' : ActorMethod<[bigint, bigint], Array<[Principal, User]>>,
  'cleanup' : ActorMethod<[string, bigint], Result>,
  'createQuestion' : ActorMethod<[string, string, string], ResultQuestion>,
  'createTeam' : ActorMethod<[string, string, TeamInfo], ResultTeam>,
  'createTestData' : ActorMethod<[string, bigint, bigint], bigint>,
  'createUser' : ActorMethod<[string, string, string], ResultUser>,
  'deleteAnswers' : ActorMethod<[string, string], ResultVoid>,
  'deleteQuestion' : ActorMethod<[string, Question, boolean], ResultVoid>,
  'deleteUser' : ActorMethod<[string], ResultVoid>,
  'getAnsweredQuestions' : ActorMethod<
    [string, bigint],
    Array<[Question, Answer]>
  >,
  'getFriends' : ActorMethod<[string], ResultFriends>,
  'getMatches' : ActorMethod<[string], ResultUserMatches>,
  'getMessages' : ActorMethod<[string, string], ResultMessages>,
  'getOwnQuestions' : ActorMethod<[string, bigint], Array<Question>>,
  'getPermissions' : ActorMethod<
    [],
    {
      'permissions' : AdminPermissions__1,
      'principal' : Principal,
      'user' : [] | [User],
    }
  >,
  'getQuestionStats' : ActorMethod<[string, bigint], ResultQuestionStats>,
  'getTeamAdmins' : ActorMethod<[string], ResultUsers>,
  'getTeamMembers' : ActorMethod<[string], ResultUsers>,
  'getTeamStats' : ActorMethod<[string], ResultTeamStats>,
  'getUnansweredQuestions' : ActorMethod<[string, bigint], Array<Question>>,
  'getUser' : ActorMethod<[], ResultUser>,
  'joinTeam' : ActorMethod<[string, string, [] | [string]], ResultTeam>,
  'leaveTeam' : ActorMethod<[string, string], ResultVoid>,
  'listAdmins' : ActorMethod<[], ResultUserPermissions>,
  'listTeams' : ActorMethod<[Array<string>], ResultTeams>,
  'listUsers' : ActorMethod<[], ResultUsersNotifications>,
  'markMessageRead' : ActorMethod<[string, string], ResultNat>,
  'sendFriendRequest' : ActorMethod<[string, string], ResultVoid>,
  'sendMessage' : ActorMethod<[string, string, string], ResultVoid>,
  'setPermissions' : ActorMethod<[string, AdminPermissions__1], ResultVoid>,
  'setTeamAdmin' : ActorMethod<[string, string, boolean], ResultTeam>,
  'submitAnswer' : ActorMethod<
    [string, QuestionID, boolean, bigint],
    ResultAnswer
  >,
  'submitSkip' : ActorMethod<[string, bigint], ResultSkip>,
  'updateProfile' : ActorMethod<[User], ResultUser>,
  'updateTeam' : ActorMethod<[string, string, TeamInfo], ResultTeam>,
  'whoami' : ActorMethod<[], Principal>,
}
export declare const idlFactory: IDL.InterfaceFactory;
export declare const init: (args: { IDL: typeof IDL }) => IDL.Type[];
