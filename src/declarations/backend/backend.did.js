export const idlFactory = ({ IDL }) => {
  const Error = IDL.Variant({
    'notInTeam' : IDL.Null,
    'notLoggedIn' : IDL.Null,
    'validationError' : IDL.Null,
    'userNotFound' : IDL.Null,
    'questionNotFound' : IDL.Null,
    'tooLong' : IDL.Null,
    'insufficientFunds' : IDL.Null,
    'permissionDenied' : IDL.Null,
    'notEnoughAnswers' : IDL.Null,
    'tooShort' : IDL.Null,
    'friendAlreadyConnected' : IDL.Null,
    'nameNotAvailable' : IDL.Null,
    'invalidInvite' : IDL.Null,
    'teamNotFound' : IDL.Null,
    'alreadyRegistered' : IDL.Null,
    'friendRequestAlreadySend' : IDL.Null,
    'notRegistered' : IDL.Principal,
    'invalidColor' : IDL.Null,
  });
  const ResultVoid = IDL.Variant({ 'ok' : IDL.Null, 'err' : Error });
  const QuestionID__1 = IDL.Nat;
  const Time = IDL.Int;
  const StableQuestion = IDL.Record({
    'id' : QuestionID__1,
    'created' : Time,
    'creator' : IDL.Principal,
    'question' : IDL.Text,
    'color' : IDL.Text,
    'hidden' : IDL.Bool,
    'showCreator' : IDL.Bool,
    'points' : IDL.Int,
  });
  const FriendStatus = IDL.Variant({
    'requestReceived' : IDL.Null,
    'connected' : IDL.Null,
    'rejectionSend' : IDL.Null,
    'rejectionReceived' : IDL.Null,
    'requestSend' : IDL.Null,
  });
  const UserStats = IDL.Record({
    'asked' : IDL.Nat,
    'answered' : IDL.Nat,
    'boosts' : IDL.Nat,
    'points' : IDL.Nat,
  });
  const User = IDL.Record({
    'created' : Time,
    'contact' : IDL.Text,
    'about' : IDL.Text,
    'username' : IDL.Text,
    'displayName' : IDL.Text,
    'picture' : IDL.Opt(IDL.Vec(IDL.Nat8)),
    'stats' : UserStats,
  });
  const Result = IDL.Variant({ 'ok' : IDL.Text, 'err' : Error });
  const Question = IDL.Record({
    'id' : QuestionID__1,
    'created' : Time,
    'creator' : IDL.Opt(IDL.Text),
    'question' : IDL.Text,
    'color' : IDL.Text,
    'points' : IDL.Int,
  });
  const ResultQuestion = IDL.Variant({ 'ok' : Question, 'err' : Error });
  const TeamInfo = IDL.Record({
    'about' : IDL.Text,
    'logo' : IDL.Vec(IDL.Nat8),
    'name' : IDL.Text,
    'listed' : IDL.Bool,
  });
  const ResultTeam = IDL.Variant({ 'ok' : TeamInfo, 'err' : Error });
  const AdminPermissions = IDL.Record({
    'becomeTeamMember' : IDL.Bool,
    'createTeam' : IDL.Bool,
    'createBackup' : IDL.Bool,
    'listAllTeams' : IDL.Bool,
    'suspendUser' : IDL.Bool,
    'editUser' : IDL.Bool,
    'restoreBackup' : IDL.Bool,
    'becomeTeamAdmin' : IDL.Bool,
  });
  const UserPermissions = IDL.Record({
    'permissions' : AdminPermissions,
    'user' : User,
  });
  const ResultUser = IDL.Variant({ 'ok' : UserPermissions, 'err' : Error });
  const Answer = IDL.Record({
    'weight' : IDL.Nat,
    'created' : Time,
    'question' : IDL.Nat,
    'answer' : IDL.Bool,
  });
  const Question__2 = IDL.Record({
    'id' : QuestionID__1,
    'created' : Time,
    'creator' : IDL.Opt(IDL.Text),
    'question' : IDL.Text,
    'color' : IDL.Text,
    'points' : IDL.Int,
  });
  const AnswerDiff = IDL.Record({
    'weight' : IDL.Nat,
    'question' : IDL.Nat,
    'sameAnswer' : IDL.Bool,
  });
  const UserInfo = IDL.Record({
    'contact' : IDL.Text,
    'about' : IDL.Text,
    'username' : IDL.Text,
    'displayName' : IDL.Text,
    'picture' : IDL.Opt(IDL.Vec(IDL.Nat8)),
  });
  const Error__1 = IDL.Variant({
    'notInTeam' : IDL.Null,
    'notLoggedIn' : IDL.Null,
    'validationError' : IDL.Null,
    'userNotFound' : IDL.Null,
    'questionNotFound' : IDL.Null,
    'tooLong' : IDL.Null,
    'insufficientFunds' : IDL.Null,
    'permissionDenied' : IDL.Null,
    'notEnoughAnswers' : IDL.Null,
    'tooShort' : IDL.Null,
    'friendAlreadyConnected' : IDL.Null,
    'nameNotAvailable' : IDL.Null,
    'invalidInvite' : IDL.Null,
    'teamNotFound' : IDL.Null,
    'alreadyRegistered' : IDL.Null,
    'friendRequestAlreadySend' : IDL.Null,
    'notRegistered' : IDL.Principal,
    'invalidColor' : IDL.Null,
  });
  const UserMatch = IDL.Record({
    'cohesion' : IDL.Nat8,
    'answered' : IDL.Vec(IDL.Tuple(Question__2, AnswerDiff)),
    'user' : UserInfo,
    'errors' : IDL.Vec(Error__1),
    'uncommon' : IDL.Vec(Question__2),
  });
  const Friend = IDL.Tuple(UserMatch, FriendStatus);
  const ResultFriends = IDL.Variant({ 'ok' : IDL.Vec(Friend), 'err' : Error });
  const ResultUserMatches = IDL.Variant({
    'ok' : IDL.Vec(UserMatch),
    'err' : Error,
  });
  const Question__1 = IDL.Record({
    'id' : QuestionID__1,
    'created' : Time,
    'creator' : IDL.Opt(IDL.Text),
    'question' : IDL.Text,
    'color' : IDL.Text,
    'points' : IDL.Int,
  });
  const QuestionStats = IDL.Record({
    'no' : IDL.Nat,
    'yes' : IDL.Nat,
    'question' : Question__1,
    'answers' : IDL.Nat,
    'boosts' : IDL.Nat,
    'skips' : IDL.Nat,
  });
  const ResultQuestionStats = IDL.Variant({
    'ok' : IDL.Vec(QuestionStats),
    'err' : Error,
  });
  const ResultUsers = IDL.Variant({ 'ok' : IDL.Vec(User), 'err' : Error });
  const TeamStats = IDL.Record({
    'answers' : IDL.Nat,
    'connections' : IDL.Nat,
    'users' : IDL.Nat,
    'questions' : IDL.Nat,
  });
  const ResultTeamStats = IDL.Variant({ 'ok' : TeamStats, 'err' : Error });
  const ResultUserPermissions = IDL.Variant({
    'ok' : IDL.Vec(UserPermissions),
    'err' : Error,
  });
  const Permissions = IDL.Record({
    'isMember' : IDL.Bool,
    'isAdmin' : IDL.Bool,
  });
  const TeamInfo__1 = IDL.Record({
    'about' : IDL.Text,
    'logo' : IDL.Vec(IDL.Nat8),
    'name' : IDL.Text,
    'listed' : IDL.Bool,
  });
  const TeamUserInfo = IDL.Record({
    'key' : IDL.Text,
    'permissions' : Permissions,
    'info' : TeamInfo__1,
    'invite' : IDL.Opt(IDL.Text),
  });
  const ResultTeams = IDL.Variant({
    'ok' : IDL.Vec(TeamUserInfo),
    'err' : Error,
  });
  const Notification = IDL.Record({
    'team' : IDL.Text,
    'event' : IDL.Variant({
      'rewards' : IDL.Nat,
      'newQuestions' : IDL.Nat,
      'friendRequests' : IDL.Nat,
    }),
  });
  const UserNotifications = IDL.Record({
    'notifications' : IDL.Vec(Notification),
    'user' : User,
  });
  const ResultUsersNotifications = IDL.Variant({
    'ok' : IDL.Vec(UserNotifications),
    'err' : Error,
  });
  const QuestionID = IDL.Nat;
  const ResultAnswer = IDL.Variant({ 'ok' : Answer, 'err' : Error });
  const Skip = IDL.Record({
    'question' : IDL.Nat,
    'reason' : IDL.Variant({ 'flag' : IDL.Null, 'skip' : IDL.Null }),
  });
  const ResultSkip = IDL.Variant({ 'ok' : Skip, 'err' : Error });
  return IDL.Service({
    'airdrop' : IDL.Func([IDL.Text, IDL.Int], [ResultVoid], []),
    'answerFriendRequest' : IDL.Func(
        [IDL.Text, IDL.Text, IDL.Bool],
        [ResultVoid],
        [],
      ),
    'backupAnswers' : IDL.Func(
        [IDL.Text, IDL.Nat, IDL.Nat],
        [IDL.Vec(StableQuestion)],
        ['query'],
      ),
    'backupConnections' : IDL.Func(
        [IDL.Text, IDL.Nat, IDL.Nat],
        [IDL.Vec(IDL.Tuple(IDL.Principal, IDL.Principal, FriendStatus))],
        ['query'],
      ),
    'backupQuestions' : IDL.Func(
        [IDL.Text, IDL.Nat, IDL.Nat],
        [IDL.Vec(StableQuestion)],
        ['query'],
      ),
    'backupUsers' : IDL.Func(
        [IDL.Nat, IDL.Nat],
        [IDL.Vec(IDL.Tuple(IDL.Principal, User))],
        ['query'],
      ),
    'cleanup' : IDL.Func([IDL.Text, IDL.Nat], [Result], []),
    'createQuestion' : IDL.Func(
        [IDL.Text, IDL.Text, IDL.Text],
        [ResultQuestion],
        [],
      ),
    'createTeam' : IDL.Func([IDL.Text, IDL.Text, TeamInfo], [ResultTeam], []),
    'createTestData' : IDL.Func([IDL.Text, IDL.Nat, IDL.Nat], [IDL.Nat], []),
    'createUser' : IDL.Func([IDL.Text, IDL.Text], [ResultUser], []),
    'deleteAnswers' : IDL.Func([IDL.Text, IDL.Text], [ResultVoid], []),
    'deleteQuestion' : IDL.Func([IDL.Text, Question], [ResultVoid], []),
    'deleteUser' : IDL.Func([IDL.Text], [ResultVoid], []),
    'getAnsweredQuestions' : IDL.Func(
        [IDL.Text, IDL.Nat],
        [IDL.Vec(IDL.Tuple(Question, Answer))],
        ['query'],
      ),
    'getFriends' : IDL.Func([IDL.Text], [ResultFriends], ['query']),
    'getMatches' : IDL.Func([IDL.Text], [ResultUserMatches], ['query']),
    'getOwnQuestions' : IDL.Func(
        [IDL.Text, IDL.Nat],
        [IDL.Vec(Question)],
        ['query'],
      ),
    'getPermissions' : IDL.Func(
        [],
        [
          IDL.Record({
            'permissions' : AdminPermissions,
            'principal' : IDL.Principal,
            'user' : IDL.Opt(User),
          }),
        ],
        ['query'],
      ),
    'getQuestionStats' : IDL.Func(
        [IDL.Text, IDL.Nat],
        [ResultQuestionStats],
        ['query'],
      ),
    'getTeamAdmins' : IDL.Func([IDL.Text], [ResultUsers], ['query']),
    'getTeamMembers' : IDL.Func([IDL.Text], [ResultUsers], ['query']),
    'getTeamStats' : IDL.Func([IDL.Text], [ResultTeamStats], ['query']),
    'getUnansweredQuestions' : IDL.Func(
        [IDL.Text, IDL.Nat],
        [IDL.Vec(Question)],
        ['query'],
      ),
    'getUser' : IDL.Func([], [ResultUser], ['query']),
    'joinTeam' : IDL.Func([IDL.Text, IDL.Text], [ResultTeam], []),
    'leaveTeam' : IDL.Func([IDL.Text, IDL.Text], [ResultVoid], []),
    'listAdmins' : IDL.Func([], [ResultUserPermissions], ['query']),
    'listTeams' : IDL.Func([IDL.Vec(IDL.Text)], [ResultTeams], ['query']),
    'listUsers' : IDL.Func([], [ResultUsersNotifications], ['query']),
    'selfDestruct' : IDL.Func([IDL.Text], [], ['oneway']),
    'sendFriendRequest' : IDL.Func([IDL.Text, IDL.Text], [ResultVoid], []),
    'setPermissions' : IDL.Func([IDL.Text, AdminPermissions], [ResultVoid], []),
    'setTeamAdmin' : IDL.Func([IDL.Text, IDL.Text, IDL.Bool], [ResultTeam], []),
    'submitAnswer' : IDL.Func(
        [IDL.Text, QuestionID, IDL.Bool, IDL.Nat],
        [ResultAnswer],
        [],
      ),
    'submitSkip' : IDL.Func([IDL.Text, IDL.Nat], [ResultSkip], []),
    'updateProfile' : IDL.Func([User], [ResultUser], []),
    'updateTeam' : IDL.Func([IDL.Text, IDL.Text, TeamInfo], [ResultTeam], []),
    'whoami' : IDL.Func([], [IDL.Principal], ['query']),
  });
};
export const init = ({ IDL }) => { return []; };
