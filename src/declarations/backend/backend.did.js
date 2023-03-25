export const idlFactory = ({ IDL }) => {
  const Result = IDL.Variant({ 'ok' : IDL.Null, 'err' : IDL.Text });
  const Gender = IDL.Variant({
    'Male' : IDL.Null,
    'Female' : IDL.Null,
    'Other' : IDL.Null,
    'Queer' : IDL.Null,
  });
  const MatchingFilter = IDL.Record({
    'cohesion' : IDL.Int,
    'ageRange' : IDL.Tuple(IDL.Nat, IDL.Nat),
    'gender' : IDL.Opt(Gender),
  });
  const Hash = IDL.Nat32;
  const Color = IDL.Variant({ 'Default' : IDL.Null });
  const Question = IDL.Record({
    'created' : IDL.Int,
    'creater' : IDL.Principal,
    'question' : IDL.Text,
    'hash' : Hash,
    'color' : IDL.Opt(Color),
    'points' : IDL.Int,
  });
  const UserMatch = IDL.Record({
    'connect' : IDL.Opt(IDL.Text),
    'about' : IDL.Opt(IDL.Text),
    'username' : IDL.Text,
    'cohesion' : IDL.Int,
    'gender' : IDL.Opt(Gender),
    'birth' : IDL.Opt(IDL.Int),
    'answeredQuestions' : IDL.Vec(Question),
  });
  const Result_3 = IDL.Variant({ 'ok' : UserMatch, 'err' : IDL.Text });
  const Result_2 = IDL.Variant({ 'ok' : IDL.Vec(Question), 'err' : IDL.Text });
  const User = IDL.Record({
    'created' : IDL.Int,
    'connect' : IDL.Tuple(IDL.Opt(IDL.Text), IDL.Bool),
    'about' : IDL.Tuple(IDL.Opt(IDL.Text), IDL.Bool),
    'username' : IDL.Text,
    'gender' : IDL.Tuple(IDL.Opt(Gender), IDL.Bool),
    'birth' : IDL.Tuple(IDL.Opt(IDL.Int), IDL.Bool),
    'points' : IDL.Nat,
    'friendRequests' : IDL.Vec(IDL.Principal),
  });
  const Result_1 = IDL.Variant({ 'ok' : User, 'err' : IDL.Text });
  const AnswerKind = IDL.Variant({ 'Bool' : IDL.Bool });
  const WeightKind = IDL.Variant({ 'Like' : IDL.Nat, 'Dislike' : IDL.Nat });
  return IDL.Service({
    'createQuestion' : IDL.Func([IDL.Text], [Result], []),
    'createUser' : IDL.Func([IDL.Text], [Result], []),
    'findMatch' : IDL.Func([MatchingFilter], [Result_3], []),
    'getAnsweredQuestions' : IDL.Func(
        [IDL.Opt(IDL.Nat)],
        [Result_2],
        ['query'],
      ),
    'getAskableQuestions' : IDL.Func([IDL.Nat], [Result_2], ['query']),
    'getUser' : IDL.Func([], [Result_1], ['query']),
    'submitAnswer' : IDL.Func([Hash, AnswerKind], [Result], []),
    'submitSkip' : IDL.Func([Hash], [Result], []),
    'submitWeight' : IDL.Func([Hash, WeightKind], [Result], []),
    'updateProfile' : IDL.Func([User], [Result], []),
  });
};
export const init = ({ IDL }) => { return []; };
