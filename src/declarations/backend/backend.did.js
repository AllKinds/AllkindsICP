export const idlFactory = ({ IDL }) => {
  const Error = IDL.Variant({
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
  const Question__1 = IDL.Record({
    'id' : QuestionID__1,
    'created' : Time__1,
    'creator' : IDL.Principal,
    'question' : IDL.Text,
    'color' : IDL.Text,
    'points' : IDL.Int,
  });
  const FriendStatus = IDL.Variant({
    'requestIgnored' : IDL.Null,
    'requestReceived' : IDL.Null,
    'connected' : IDL.Null,
    'rejectionSend' : IDL.Null,
    'rejectionReceived' : IDL.Null,
    'requestSend' : IDL.Null,
  });
  const IsPublic = IDL.Bool;
  const Time = IDL.Int;
  const SocialNetwork = IDL.Variant({
    'mastodon' : IDL.Null,
    'twitter' : IDL.Null,
    'email' : IDL.Null,
    'distrikt' : IDL.Null,
    'phone' : IDL.Null,
    'dscvr' : IDL.Null,
  });
  const Social = IDL.Record({ 'network' : SocialNetwork, 'handle' : IDL.Text });
  const Gender = IDL.Variant({
    'Male' : IDL.Null,
    'Female' : IDL.Null,
    'Other' : IDL.Null,
    'Queer' : IDL.Null,
  });
  const User = IDL.Record({
    'age' : IDL.Tuple(IDL.Opt(IDL.Nat8), IsPublic),
    'created' : Time,
    'about' : IDL.Tuple(IDL.Opt(IDL.Text), IsPublic),
    'username' : IDL.Text,
    'socials' : IDL.Vec(IDL.Tuple(Social, IsPublic)),
    'picture' : IDL.Tuple(IDL.Opt(IDL.Vec(IDL.Nat8)), IsPublic),
    'gender' : IDL.Tuple(IDL.Opt(Gender), IsPublic),
    'points' : IDL.Nat,
  });
  const ResultQuestion = IDL.Variant({ 'ok' : Question__1, 'err' : Error });
  const ResultUser = IDL.Variant({ 'ok' : User, 'err' : Error });
  const Question = IDL.Record({
    'id' : QuestionID__1,
    'created' : Time__1,
    'creator' : IDL.Principal,
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
    'age' : IDL.Opt(IDL.Nat8),
    'about' : IDL.Opt(IDL.Text),
    'username' : IDL.Text,
    'socials' : IDL.Vec(Social),
    'picture' : IDL.Opt(IDL.Vec(IDL.Nat8)),
    'gender' : IDL.Opt(Gender),
  });
  const UserMatch = IDL.Record({
    'cohesion' : IDL.Nat8,
    'answered' : IDL.Vec(IDL.Tuple(Question, AnswerDiff)),
    'user' : UserInfo,
    'uncommon' : IDL.Vec(Question),
  });
  const ResultUserMatch = IDL.Variant({ 'ok' : UserMatch, 'err' : Error });
  const Answer = IDL.Record({
    'weight' : IDL.Nat,
    'question' : IDL.Nat,
    'answer' : IDL.Bool,
  });
  const ResultFriends = IDL.Variant({
    'ok' : IDL.Vec(IDL.Tuple(UserMatch, FriendStatus)),
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
    'answerFriendRequest' : IDL.Func([IDL.Text, IDL.Bool], [Result], []),
    'backupAnswers' : IDL.Func(
        [IDL.Nat, IDL.Nat],
        [IDL.Vec(Question__1)],
        ['query'],
      ),
    'backupConnections' : IDL.Func(
        [IDL.Nat, IDL.Nat],
        [IDL.Vec(IDL.Tuple(IDL.Principal, IDL.Principal, FriendStatus))],
        ['query'],
      ),
    'backupQuestions' : IDL.Func(
        [IDL.Nat, IDL.Nat],
        [IDL.Vec(Question__1)],
        ['query'],
      ),
    'backupUsers' : IDL.Func(
        [IDL.Nat, IDL.Nat],
        [IDL.Vec(IDL.Tuple(IDL.Principal, User))],
        ['query'],
      ),
    'createQuestion' : IDL.Func([IDL.Text, IDL.Text], [ResultQuestion], []),
    'createUser' : IDL.Func([IDL.Text], [ResultUser], []),
    'findMatch' : IDL.Func(
        [IDL.Nat8, IDL.Nat8, IDL.Opt(Gender), IDL.Nat8, IDL.Nat8],
        [ResultUserMatch],
        [],
      ),
    'getAnsweredQuestions' : IDL.Func(
        [IDL.Nat],
        [IDL.Vec(IDL.Tuple(Question__1, Answer))],
        ['query'],
      ),
    'getAskableQuestions' : IDL.Func(
        [IDL.Nat],
        [IDL.Vec(Question__1)],
        ['query'],
      ),
    'getFriends' : IDL.Func([], [ResultFriends], ['query']),
    'getUser' : IDL.Func([], [ResultUser], ['query']),
    'selfDestruct' : IDL.Func([IDL.Text], [], ['oneway']),
    'sendFriendRequest' : IDL.Func([IDL.Text], [Result], []),
    'submitAnswer' : IDL.Func(
        [QuestionID, IDL.Bool, IDL.Nat],
        [ResultAnswer],
        [],
      ),
    'submitSkip' : IDL.Func([IDL.Nat], [ResultSkip], []),
    'updateProfile' : IDL.Func([User], [ResultUser], []),
    'whoami' : IDL.Func([], [IDL.Principal], ['query']),
  });
};
export const init = ({ IDL }) => { return []; };
