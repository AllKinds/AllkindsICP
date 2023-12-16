export const idlFactory = ({ IDL }) => {
  const Error = IDL.Variant({
    'notInTeam' : IDL.Null,
    'notLoggedIn' : IDL.Null,
    'validationError' : IDL.Null,
    'userNotFound' : IDL.Null,
    'tooLong' : IDL.Null,
    'insufficientFunds' : IDL.Null,
    'notEnoughAnswers' : IDL.Null,
    'tooShort' : IDL.Null,
    'friendAlreadyConnected' : IDL.Null,
    'nameNotAvailable' : IDL.Null,
    'alreadyRegistered' : IDL.Null,
    'friendRequestAlreadySend' : IDL.Null,
    'notRegistered' : IDL.Null,
    'invalidColor' : IDL.Null,
  });
  const Result = IDL.Variant({ 'ok' : IDL.Null, 'err' : Error });
  const QuestionID__1 = IDL.Nat;
  const Time__1 = IDL.Int;
  const StableQuestion = IDL.Record({
    'id' : QuestionID__1,
    'created' : Time__1,
    'creator' : IDL.Principal,
    'question' : IDL.Text,
    'color' : IDL.Text,
    'points' : IDL.Int,
  });
  const FriendStatus = IDL.Variant({
    'requestReceived' : IDL.Null,
    'connected' : IDL.Null,
    'rejectionSend' : IDL.Null,
    'rejectionReceived' : IDL.Null,
    'requestSend' : IDL.Null,
  });
  const Time = IDL.Int;
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
  const Question = IDL.Record({
    'id' : QuestionID__1,
    'created' : Time__1,
    'creator' : IDL.Opt(IDL.Text),
    'question' : IDL.Text,
    'color' : IDL.Text,
    'points' : IDL.Int,
  });
  const ResultQuestion = IDL.Variant({ 'ok' : Question, 'err' : Error });
  const ResultUser = IDL.Variant({ 'ok' : User, 'err' : Error });
  const Answer = IDL.Record({
    'weight' : IDL.Nat,
    'created' : Time__1,
    'question' : IDL.Nat,
    'answer' : IDL.Bool,
  });
  const Question__1 = IDL.Record({
    'id' : QuestionID__1,
    'created' : Time__1,
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
  const UserMatch = IDL.Record({
    'cohesion' : IDL.Nat8,
    'answered' : IDL.Vec(IDL.Tuple(Question__1, AnswerDiff)),
    'user' : UserInfo,
    'uncommon' : IDL.Vec(Question__1),
  });
  const Friend = IDL.Tuple(UserMatch, FriendStatus);
  const ResultFriends = IDL.Variant({ 'ok' : IDL.Vec(Friend), 'err' : Error });
  const ResultUserMatches = IDL.Variant({
    'ok' : IDL.Vec(UserMatch),
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
    'airdrop' : IDL.Func([IDL.Text, IDL.Int], [Result], []),
    'answerFriendRequest' : IDL.Func(
        [IDL.Text, IDL.Text, IDL.Bool],
        [Result],
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
    'createQuestion' : IDL.Func(
        [IDL.Text, IDL.Text, IDL.Text],
        [ResultQuestion],
        [],
      ),
    'createTestData' : IDL.Func([IDL.Text, IDL.Nat, IDL.Nat], [IDL.Nat], []),
    'createUser' : IDL.Func([IDL.Text, IDL.Text], [ResultUser], []),
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
    'getUnansweredQuestions' : IDL.Func(
        [IDL.Text, IDL.Nat],
        [IDL.Vec(Question)],
        ['query'],
      ),
    'getUser' : IDL.Func([], [ResultUser], ['query']),
    'selfDestruct' : IDL.Func([IDL.Text], [], ['oneway']),
    'sendFriendRequest' : IDL.Func([IDL.Text, IDL.Text], [Result], []),
    'submitAnswer' : IDL.Func(
        [IDL.Text, QuestionID, IDL.Bool, IDL.Nat],
        [ResultAnswer],
        [],
      ),
    'submitSkip' : IDL.Func([IDL.Text, IDL.Nat], [ResultSkip], []),
    'updateProfile' : IDL.Func([User], [ResultUser], []),
    'whoami' : IDL.Func([], [IDL.Principal], ['query']),
  });
};
export const init = ({ IDL }) => { return []; };
