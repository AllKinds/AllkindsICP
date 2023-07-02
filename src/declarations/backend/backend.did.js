export const idlFactory = ({ IDL }) => {
  const Error = IDL.Variant({
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
  const Time__1 = IDL.Int;
  const Question__1 = IDL.Record({
    'id' : IDL.Nat,
    'created' : Time__1,
    'creator' : IDL.Principal,
    'question' : IDL.Text,
    'color' : IDL.Text,
    'points' : IDL.Int,
  });
  const ResultQuestion = IDL.Variant({ 'ok' : Question__1, 'err' : Error });
  const Time = IDL.Int;
  const IsPublic = IDL.Bool;
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
    'created' : Time,
    'about' : IDL.Tuple(IDL.Opt(IDL.Text), IsPublic),
    'username' : IDL.Text,
    'socials' : IDL.Vec(IDL.Tuple(Social, IsPublic)),
    'picture' : IDL.Tuple(IDL.Opt(IDL.Vec(IDL.Nat8)), IsPublic),
    'gender' : IDL.Tuple(IDL.Opt(Gender), IsPublic),
    'birth' : IDL.Tuple(IDL.Opt(Time), IsPublic),
    'points' : IDL.Nat,
  });
  const ResultUser = IDL.Variant({ 'ok' : User, 'err' : Error });
  const Question = IDL.Record({
    'id' : IDL.Nat,
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
    'about' : IDL.Opt(IDL.Text),
    'username' : IDL.Text,
    'socials' : IDL.Vec(Social),
    'picture' : IDL.Opt(IDL.Vec(IDL.Nat8)),
    'gender' : IDL.Opt(Gender),
    'birth' : IDL.Opt(Time),
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
  const ResultUserMatches = IDL.Variant({
    'ok' : IDL.Vec(UserMatch),
    'err' : Error,
  });
  const ResultAnswer = IDL.Variant({ 'ok' : Answer, 'err' : Error });
  const Skip = IDL.Record({
    'question' : IDL.Nat,
    'reason' : IDL.Variant({ 'flag' : IDL.Null, 'skip' : IDL.Null }),
  });
  const ResultSkip = IDL.Variant({ 'ok' : Skip, 'err' : Error });
  return IDL.Service({
    'answerFriendRequest' : IDL.Func([IDL.Text, IDL.Bool], [Result], []),
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
    'getFriends' : IDL.Func([], [ResultUserMatches], ['query']),
    'getUser' : IDL.Func([], [ResultUser], ['query']),
    'sendFriendRequest' : IDL.Func([IDL.Text], [Result], []),
    'submitAnswer' : IDL.Func([IDL.Nat, IDL.Bool, IDL.Nat], [ResultAnswer], []),
    'submitSkip' : IDL.Func([IDL.Nat], [ResultSkip], []),
    'updateProfile' : IDL.Func([User], [ResultUser], []),
    'whoami' : IDL.Func([], [IDL.Principal], ['query']),
  });
};
export const init = ({ IDL }) => { return []; };
