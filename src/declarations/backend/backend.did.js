export const idlFactory = ({ IDL }) => {
	const Result = IDL.Variant({ ok: IDL.Null, err: IDL.Text });
	const Gender = IDL.Variant({
		Male: IDL.Null,
		Female: IDL.Null,
		Other: IDL.Null,
		Queer: IDL.Null
	});
	const MatchingFilter = IDL.Record({
		cohesion: IDL.Nat,
		ageRange: IDL.Tuple(IDL.Nat, IDL.Nat),
		gender: IDL.Opt(Gender)
	});
	const User = IDL.Record({
		created: IDL.Int,
		connect: IDL.Tuple(IDL.Opt(IDL.Text), IDL.Bool),
		about: IDL.Tuple(IDL.Opt(IDL.Text), IDL.Bool),
		username: IDL.Text,
		gender: IDL.Tuple(IDL.Opt(Gender), IDL.Bool),
		birth: IDL.Tuple(IDL.Opt(IDL.Int), IDL.Bool),
		points: IDL.Nat
	});
	const Result_3 = IDL.Variant({
		ok: IDL.Vec(IDL.Tuple(User, IDL.Int)),
		err: IDL.Text
	});
	const Hash = IDL.Nat32;
	const Color = IDL.Variant({ Default: IDL.Null });
	const Question = IDL.Record({
		created: IDL.Int,
		creater: IDL.Principal,
		question: IDL.Text,
		hash: Hash,
		color: IDL.Opt(Color),
		points: IDL.Int
	});
	const Result_2 = IDL.Variant({ ok: IDL.Vec(Question), err: IDL.Text });
	const Result_1 = IDL.Variant({ ok: User, err: IDL.Text });
	const AnswerKind = IDL.Variant({ Bool: IDL.Bool });
	const LikeKind = IDL.Variant({ Like: IDL.Nat, Dislike: IDL.Nat });
	return IDL.Service({
		createQuestion: IDL.Func([IDL.Text], [Result], []),
		createUser: IDL.Func([IDL.Text], [Result], []),
		findMatches: IDL.Func([MatchingFilter], [Result_3], []),
		getAnsweredQuestions: IDL.Func([IDL.Nat], [Result_2], ['query']),
		getAskableQuestions: IDL.Func([IDL.Nat], [Result_2], ['query']),
		getUser: IDL.Func([], [Result_1], ['query']),
		submitAnswer: IDL.Func([Hash, AnswerKind], [Result], []),
		submitLike: IDL.Func([Hash, LikeKind], [Result], []),
		submitSkip: IDL.Func([Hash], [Result], []),
		updateProfile: IDL.Func([User], [Result], [])
	});
};
export const init = ({ IDL }) => {
	return [];
};
