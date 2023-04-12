export const idlFactory = ({ IDL }) => {
	const Result = IDL.Variant({ ok: IDL.Null, err: IDL.Text });
	const Gender = IDL.Variant({
		Male: IDL.Null,
		Female: IDL.Null,
		Other: IDL.Null,
		Queer: IDL.Null
	});
	const MatchingFilter = IDL.Record({
		cohesion: IDL.Int,
		ageRange: IDL.Tuple(IDL.Nat, IDL.Nat),
		gender: IDL.Opt(Gender)
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
	const UserMatch = IDL.Record({
		principal: IDL.Principal,
		connect: IDL.Opt(IDL.Text),
		about: IDL.Opt(IDL.Text),
		username: IDL.Text,
		cohesion: IDL.Int,
		answered: IDL.Vec(IDL.Tuple(Question, IDL.Bool)),
		gender: IDL.Opt(Gender),
		birth: IDL.Opt(IDL.Int),
		uncommon: IDL.Vec(Question)
	});
	const Result_4 = IDL.Variant({ ok: UserMatch, err: IDL.Text });
	const Result_3 = IDL.Variant({ ok: IDL.Vec(Question), err: IDL.Text });
	const FriendStatus = IDL.Variant({
		Approved: IDL.Null,
		Waiting: IDL.Null,
		Requested: IDL.Null
	});
	const FriendlyUserMatch = IDL.Record({
		status: FriendStatus,
		principal: IDL.Principal,
		connect: IDL.Opt(IDL.Text),
		about: IDL.Opt(IDL.Text),
		username: IDL.Text,
		cohesion: IDL.Int,
		answered: IDL.Vec(IDL.Tuple(Question, IDL.Bool)),
		gender: IDL.Opt(Gender),
		birth: IDL.Opt(IDL.Int),
		uncommon: IDL.Vec(Question)
	});
	const Result_2 = IDL.Variant({
		ok: IDL.Vec(FriendlyUserMatch),
		err: IDL.Text
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
	const Result_1 = IDL.Variant({ ok: User, err: IDL.Text });
	return IDL.Service({
		answerFriendRequest: IDL.Func([IDL.Principal, IDL.Bool], [Result], []),
		createQuestion: IDL.Func([IDL.Text], [Result], []),
		createUser: IDL.Func([IDL.Text], [Result], []),
		findMatch: IDL.Func([MatchingFilter], [Result_4], []),
		getAnsweredQuestions: IDL.Func([IDL.Opt(IDL.Nat)], [Result_3], ['query']),
		getAskableQuestions: IDL.Func([IDL.Nat], [Result_3], ['query']),
		getFriends: IDL.Func([], [Result_2], ['query']),
		getUser: IDL.Func([], [Result_1], ['query']),
		sendFriendRequest: IDL.Func([IDL.Principal], [Result], []),
		submitAnswer: IDL.Func([Hash, IDL.Bool, IDL.Int], [Result], []),
		submitSkip: IDL.Func([Hash], [Result], []),
		updateProfile: IDL.Func([User], [Result], [])
	});
};
export const init = ({ IDL }) => {
	return [];
};
