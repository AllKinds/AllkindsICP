import Principal "mo:base/Principal";
import Hash "mo:base/Hash";
import List "mo:base/List";
import HashMap "mo:base/HashMap";
import Int "mo:base/Int";
import Text "mo:base/Text";
import Result "mo:base/Result";
import Time "mo:base/Time";
import Iter "mo:base/Iter";
import Option "mo:base/Option";
import Buffer "mo:base/Buffer";
import Nat32 "mo:base/Nat32";
import Debug "mo:base/Debug";
import Array "mo:base/Array";

actor {

	// CONSTANTS
	let N = 10;

	// DATA TYPES

	// User type, tuple values contain a bool indicating field public visibility and optional value
	type User = {
		username : Text;
		created : Int;
		about : (?Text, Bool);
		gender : (?Gender, Bool);
		birth : (?Int, Bool);
		connect : (?Text, Bool);
	};

	type Gender = {
		#Male;
		#Female;
		#Queer;
		#Other;
	};

	// Color indicates optional background color for the question
	type Question = {
		created : Int;
		creater : Principal;
		question : Text;
		hash : Hash.Hash;
		color : ?Color;
	};

	// Only one color for now
	type Color = {
		#Default;
	};

	type Answer = {
		user : Principal;
		question : Hash.Hash;
		answer : AnswerKind;
	};

	type Like = {
		user : Principal;
		question : Hash.Hash;
		like : LikeKind;
	};

	type Skip = {
		user : Principal;
		question : Hash.Hash;
	};

	// Only one answer type for now
	type AnswerKind = {
		#Bool : Bool;
	};

	// Nat indicates a possible amount of tokens / points appointed by the user to to the question
	type LikeKind = {
		#Like : Nat;
		#Dislike : Nat;
	};

	type PrincipalQuestionHash = Hash.Hash;

	type CommonQuestion = {
		question : Hash.Hash;
		sourceAnswer : Answer;
		testAnswer : Answer;
		sourceLike : ?Like;
		testLike : ?Like;
	};

	// UTILITY FUNCTIONS

	func hashQuestion(created : Int, creater : Principal, question : Text) : Hash.Hash {
		let t1 = Int.toText(created);
		let t2 = Principal.toText(creater);
		let t3 = question;
		Text.hash(t1 # t2 # t3);
	};

	func hashPrincipalQuestion(p : Principal, questionHash : Hash.Hash) : Hash.Hash {
		let t1 = Principal.toText(p);
		let t2 = Nat32.toText(questionHash);
		Text.hash(t1 # t2);
	};

	func hashhash(h : Hash.Hash) : Hash.Hash { h };

	func putQuestion(p : Principal, question : Text) : () {
		let created = Time.now();
		let creater = p;
		let hash = hashQuestion(created, creater, question);
		let color = ?#Default;

		let q : Question = {
			created;
			creater;
			question;
			hash;
			color;
		};

		questions.put(hash, q);
	};

	func putAnswer(p : Principal, answer : Answer) : () {
		let pQ = hashPrincipalQuestion(p, answer.question);
		answers.put(pQ, answer);
	};

	func putLike(p : Principal, like : Like) : () {
		let pQ = hashPrincipalQuestion(p, like.question);
		likes.put(pQ, like);
	};

	func putSkip(p : Principal, skip : Skip) : () {
		let pQ = hashPrincipalQuestion(p, skip.question);
		skips.put(pQ, skip);
	};

	func askableQuestions(p : Principal) : [Hash.Hash] {
		let buf = Buffer.Buffer<Hash.Hash>(10);
		for (hash in questions.keys()) {
			let pQ = hashPrincipalQuestion(p, hash);
			switch (skips.get(pQ)) {
				case (?_) {};
				case null {
					switch (likes.get(pQ)) {
						case (?_) {};
						case null {
							switch (answers.get(pQ)) {
								case (?_) {};
								case null {
									buf.add(hash);
								};
							};
						};
					};
				};
			};
		};
		buf.toArray();
	};

	// calc score for 2 answers and optional 2 likes
	func calcQuestionScore(sourceAnswer : Answer, testAnswer : Answer, sourceLike : ?Like, testLike : ?Like) : Int {
		assert (sourceAnswer.question == testAnswer.question);

		let hasLikes = Option.isSome(sourceLike) and Option.isSome(testLike);
		let hasNoLikes = Option.isNull(sourceLike) and Option.isNull(testLike);
		assert (hasLikes or hasNoLikes);

		let sourceAnswerScore : Int = if (sourceAnswer.answer == #Bool(true)) {
			1;
		} else { -1 };

		let testAnswerScore : Int = if (testAnswer.answer == #Bool(true)) { 1 } else {
			-1;
		};

		let sourceLikeScore : Int = switch (sourceLike) {
			case (?sourceLike) {
				switch (sourceLike.like) {
					case (#Like(score)) { score };
					case (#Dislike(score)) { -score };
				};
			};
			case null { 1 };
		};

		let testLikeScore : Int = switch (testLike) {
			case (?testLike) {
				switch (testLike.like) {
					case (#Like(score)) { score };
					case (#Dislike(score)) { -score };
				};
			};
			case null { 1 };
		};

		sourceAnswerScore * testAnswerScore * sourceLikeScore * testLikeScore;
	};

	func hasAnswered(p : Principal, question : Hash.Hash) : ?Answer {
		let pQ = hashPrincipalQuestion(p, question);
		switch (answers.get(pQ)) {
			case null { return null };
			case (?answer) { return ?answer };
		};
	};

	func hasliked(p : Principal, question : Hash.Hash) : ?Like {
		let pQ = hashPrincipalQuestion(p, question);
		switch (likes.get(pQ)) {
			case null return null;
			case (?like) { return ?like };
		};
	};

	func commonQuestions(sourceUser : Principal, testUser : Principal) : [CommonQuestion] {
		let buf = Buffer.Buffer<CommonQuestion>(2);
		for (hash in questions.keys()) {
			let sourcePQ = hashPrincipalQuestion(sourceUser, hash);
			let testPQ = hashPrincipalQuestion(testUser, hash);
			switch (answers.get(sourcePQ)) {
				case null {};
				case (?sourceAnswer) {
					switch (answers.get(testPQ)) {
						case null {};
						case (?testAnswer) {
							let sourceLike = likes.get(sourcePQ);
							let testLike = likes.get(testPQ);
							let commonQuestion : CommonQuestion = {
								question = hash;
								sourceAnswer;
								testAnswer;
								sourceLike;
								testLike;
							};
							buf.add(commonQuestion);
						};
					};
				};
			};
		};
		buf.toArray();
	};

	func calcScore(sourceUser : Principal, testUser : Principal) : Int {
		let common = commonQuestions(sourceUser, testUser);
		var score : Int = 0;
		for (q in Iter.fromArray(common)) {
			score += calcQuestionScore(
				q.sourceAnswer,
				q.testAnswer,
				q.sourceLike,
				q.testLike
			);
		};
		score;
	};

	// DATA STORAGE

	stable var stableUsers : [(Principal, User)] = [];
	let users = HashMap.fromIter<Principal, User>(Iter.fromArray(stableUsers), 100, Principal.equal, Principal.hash);

	stable var stableQuestions : [(Hash.Hash, Question)] = [];
	let questions = HashMap.fromIter<Hash.Hash, Question>(Iter.fromArray(stableQuestions), 100, Hash.equal, hashhash);

	stable var stableAnswers : [(PrincipalQuestionHash, Answer)] = [];
	let answers = HashMap.fromIter<PrincipalQuestionHash, Answer>(Iter.fromArray(stableAnswers), 100, Hash.equal, hashhash);

	stable var stableLikes : [(PrincipalQuestionHash, Like)] = [];
	let likes = HashMap.fromIter<PrincipalQuestionHash, Like>(Iter.fromArray(stableLikes), 100, Hash.equal, hashhash);

	stable var stableSkips : [(PrincipalQuestionHash, Skip)] = [];
	let skips = HashMap.fromIter<PrincipalQuestionHash, Skip>(Iter.fromArray(stableSkips), 100, Hash.equal, hashhash);

	// Upgrade canister
	system func preupgrade() {
		stableUsers := Iter.toArray(users.entries());
		stableQuestions := Iter.toArray(questions.entries());
		stableAnswers := Iter.toArray(answers.entries());
		stableLikes := Iter.toArray(likes.entries());
		stableSkips := Iter.toArray(skips.entries());
	};

	system func postupgrade() {
		stableUsers := [];
		stableQuestions := [];
		stableAnswers := [];
		stableLikes := [];
		stableSkips := [];
	};

	// PUBLIC API

	// Create default new user with only a username
	public shared (msg) func createUser(username : Text) : async Result.Result<(), Text> {
		let caller = msg.caller;
		let created = Time.now();

		switch (users.get(caller)) {
			case (?_) return #err("User is already registered!");
			case null {
				let user : User = {
					username;
					created;
					about = (null, false);
					gender = (null, false);
					birth = (null, false);
					connect = (null, false);
				};

				// Mutate storage for users data
				users.put(caller, user);
				#ok();
			};
		};
	};

	public shared query (msg) func getUser() : async Result.Result<User, Text> {
		switch (users.get(msg.caller)) {
			case (?user) return #ok(user);
			case null return #err("User does not exist!");
		};
	};

	public shared (msg) func updateProfile(user : User) : async Result.Result<(), Text> {
		switch (users.get(msg.caller)) {
			case null { return #err("User does not exist!") };
			case (?_) {
				users.put(msg.caller, user);
			};
		};
		#ok();
	};

	// Create a new question with default color
	public shared (msg) func createQuestion(question : Text) : async Result.Result<(), Text> {
		switch (users.get(msg.caller)) {
			case null return #err("User does not exist");
			case (?user) {
				putQuestion(msg.caller, question);
			};
		};
		#ok();
	};

	public shared query (msg) func getAskableQuestions() : async Result.Result<[Question], Text> {
		let askables = askableQuestions(msg.caller);

		func getQuestion(h : Hash.Hash) : ?Question {
			questions.get(h);
		};

		let q = Array.mapFilter(askables, getQuestion);

		#ok(q);
	};

	// Add an answer
	public shared (msg) func submitAnswer(question : Hash.Hash, answer : AnswerKind) : async Result.Result<(), Text> {
		let principalQuestion = hashPrincipalQuestion(msg.caller, question);
		let newAnswer = {
			user = msg.caller;
			question;
			answer;
		};
		answers.put(principalQuestion, newAnswer);
		#ok();
	};

	// // Add a like
	public shared (msg) func submitLike(question : Hash.Hash, like : LikeKind) : async Result.Result<(), Text> {
		let principalQuestion = hashPrincipalQuestion(msg.caller, question);
		let newLike = {
			user = msg.caller;
			question;
			like;
		};
		likes.put(principalQuestion, newLike);
		#ok();
	};

	// Add a skip
	public shared (msg) func submitSkip(question : Hash.Hash) : async Result.Result<(), Text> {
		let principalQuestion = hashPrincipalQuestion(msg.caller, question);
		let skip = {
			user = msg.caller;
			question;
		};
		skips.put(principalQuestion, skip);
		#ok();
	};
};
