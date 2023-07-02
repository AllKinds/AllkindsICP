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
  const Result_3 = IDL.Variant({ 'ok' : IDL.Null, 'err' : Error });
  const Time__1 = IDL.Int;
  const Question__1 = IDL.Record({
    'id' : IDL.Nat,
    'created' : Time__1,
    'creator' : IDL.Principal,
    'question' : IDL.Text,
    'color' : IDL.Text,
    'points' : IDL.Int,
  });
  const Result_6 = IDL.Variant({ 'ok' : Question__1, 'err' : Error });
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
  const Result = IDL.Variant({ 'ok' : User, 'err' : Error });
  const UserFilter = IDL.Record({
    'maxBirth' : Time,
    'gender' : IDL.Opt(Gender),
    'minBirth' : Time,
  });
  const MatchingFilter = IDL.Record({
    'cohesion' : IDL.Nat8,
    'users' : UserFilter,
  });
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
  const Result_5 = IDL.Variant({ 'ok' : UserMatch, 'err' : Error });
  const Answer = IDL.Record({
    'weight' : IDL.Nat,
    'question' : IDL.Nat,
    'answer' : IDL.Bool,
  });
  const Result_4 = IDL.Variant({ 'ok' : IDL.Vec(UserMatch), 'err' : Error });
  const Result_2 = IDL.Variant({ 'ok' : Answer, 'err' : Error });
  const Skip = IDL.Record({
    'question' : IDL.Nat,
    'reason' : IDL.Variant({ 'flag' : IDL.Null, 'skip' : IDL.Null }),
  });
  const Result_1 = IDL.Variant({ 'ok' : Skip, 'err' : Error });
  return IDL.Service({
    'answerFriendRequest' : IDL.Func([IDL.Text, IDL.Bool], [Result_3], []),
    'createQuestion' : IDL.Func([IDL.Text, IDL.Text], [Result_6], []),
    'createUser' : IDL.Func([IDL.Text], [Result], []),
    'findMatch' : IDL.Func([MatchingFilter], [Result_5], []),
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
    'getFriends' : IDL.Func([], [Result_4], ['query']),
    'getUser' : IDL.Func([], [Result], ['query']),
    'sendFriendRequest' : IDL.Func([IDL.Text], [Result_3], []),
    'submitAnswer' : IDL.Func([IDL.Nat, IDL.Bool, IDL.Nat], [Result_2], []),
    'submitSkip' : IDL.Func([IDL.Nat], [Result_1], []),
    'updateProfile' : IDL.Func([User], [Result], []),
    'whoami' : IDL.Func([], [IDL.Principal], ['query']),
  });
};
export const init = ({ IDL }) => { return []; };
