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
import Nat8 "mo:base/Nat8";
import Nat "mo:base/Nat";
import Int8 "mo:base/Int8";
import Int32 "mo:base/Int32";
import Debug "mo:base/Debug";
import Array "mo:base/Array";
import Float "mo:base/Float";
import Order "mo:base/Order";
import None "mo:base/None";

actor {

	//TODO : change hashmaps and buffer inital sizes, every double does take some cost to double
	//better a fair amount value instead of small values like 2 for buffs that eventually grow way bigger
	//TODO : use more hashmaps for bigger calculations

	// CONSTANTS
	let N = 10;
	//TODO : change 'points' to 'reward'
	let initReward : Nat = 10000;
	let answerReward : Nat = 2;
	let createrReward : Nat = 10;
	let queryCost : Nat = 30;

	// DATA TYPES

	// User type, tuple values contain a bool indicating field public visibility and optional value
	type User = {
		username : Text;
		created : Int;
		about : (?Text, Bool);
		gender : (?Gender, Bool);
		birth : (?Int, Bool);
		connect : (?Text, Bool);
		points : Nat; //Nat bcs user points should not go negative
	};

	type UserMatch = {
		username : Text;
		about : ?Text;
		gender : ?Gender;
		birth : ?Int;
		connect : ?Text;
		//TEMP changed into score for testing : cohesion : Nat; //should always between 0-100, maybe nat8
		cohesion : Int;
		answeredQuestions : [Question];
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
		points : Int; //int bcs question points should be able to go negative
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

	type Weight = {
		user : Principal;
		question : Hash.Hash;
		weight : WeightKind; //this would need to become an Int
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
	type WeightKind = {
		//this would need to be removed
		#Like : Nat;
		#Dislike : Nat;
	};

	type PrincipalQuestionHash = Hash.Hash;

	type CommonQuestion = {
		question : Hash.Hash;
		sourceAnswer : Answer;
		testAnswer : Answer;
		sourceWeight : ?Weight;
		testWeight : ?Weight;
	};

	type MatchingFilter = {
		ageRange : (Nat, Nat);
		gender : ?Gender;
		cohesion : Int;
	};

	type UserWScore = (Principal, Int);

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
		let points : Int = 0;

		let q : Question = {
			created;
			creater;
			question;
			hash;
			color;
			points;
		};

		questions.put(hash, q);
	};

	func putAnswer(p : Principal, answer : Answer) : () {
		let pQ = hashPrincipalQuestion(p, answer.question);
		answers.put(pQ, answer);
	};

	func putWeight(p : Principal, weight : Weight) : () {
		let pQ = hashPrincipalQuestion(p, weight.question);
		weights.put(pQ, weight);
	};

	func putSkip(p : Principal, skip : Skip) : () {
		let pQ = hashPrincipalQuestion(p, skip.question);
		skips.put(pQ, skip);
	};

	func askableQuestions(p : Principal, n : Nat) : [Hash.Hash] {
		let buf = Buffer.Buffer<Hash.Hash>(10);
		var count = 0;
		label f for (hash in questions.keys()) {
			if (n == count) break f;
			let pQ = hashPrincipalQuestion(p, hash);
			if (null == skips.get(pQ)) if (null == weights.get(pQ)) if (null == answers.get(pQ)) {
				buf.add(hash);
				count += 1;
			};
		};
		buf.toArray();
	};

	func answeredQuestions(p : Principal, n : ?Nat) : [Hash.Hash] {
		let buf = Buffer.Buffer<Hash.Hash>(10);
		var count = 0;
		label f for (hash in questions.keys()) {
			switch (n) {
				case null {};
				case (?n) {
					if (n == count) break f;
				};
			};
			let pQ = hashPrincipalQuestion(p, hash);
			switch (skips.get(pQ)) {
				case (?_) {};
				case null {
					switch (weights.get(pQ)) {
						case (?_) {};
						case null {
							switch (answers.get(pQ)) {
								case (?_) {
									buf.add(hash);
									count += 1;
								};
								case null {};
							};
						};
					};
				};
			};
		};
		buf.toArray();
	};

	// calc score for 2 answers and optional 2 weights
	func calcQuestionScore(sourceAnswer : Answer, testAnswer : Answer, sourceWeight : ?Weight, testWeight : ?Weight) : Int {
		assert (sourceAnswer.question == testAnswer.question);

		// let hasWeights = Option.isSome(sourceWeight) and Option.isSome(testWeight);
		// let hasNoWeights = Option.isNull(sourceWeight) and Option.isNull(testWeight);

		let compareAnswers : Bool = sourceAnswer.answer == testAnswer.answer;
		//let compareWeights : Bool = ...

		//Weights should be: both positive, or both negative. -> and result both in +value

		if (compareAnswers == false) {
			//also check for weights here
			return 0;
		} else {
			// let sourceAnswerScore : Int = if (sourceAnswer.answer == #Bool(true)) { 1 } else { -1 };
			// let testAnswerScore : Int = if (testAnswer.answer == #Bool(true)) { 1 } else { -1 };

			//functions remade with possible changed weight type
			let sourceWeightScore : Int = switch (sourceWeight) {
				case (?sourceWeight) {
					switch (sourceWeight.weight) {
						case (#Like(score)) { score };
						case (#Dislike(score)) { -score };
					};
				};
				case null { 1 };
			};

			let testWeightScore : Int = switch (testWeight) {
				case (?testWeight) {
					switch (testWeight.weight) {
						case (#Like(score)) { score };
						case (#Dislike(score)) { -score };
					};
				};
				case null { 1 };
			};

			var wScore : Int = 1; //temp ugly fix
			//init score with 1 so people can match even if they didnt weigh but still answered the same
			if (sourceWeightScore >= 0 and testWeightScore >= 0) {
				wScore += sourceWeightScore + testWeightScore;
			};
			if (sourceWeightScore <= 0 and testWeightScore <= 0) {
				wScore += sourceWeightScore + testWeightScore;
			};
			return wScore;
		};
	};

	func hasAnswered(p : Principal, question : Hash.Hash) : ?Answer {
		let pQ = hashPrincipalQuestion(p, question);
		let answer = do { answers.get(pQ) };
		return answer;
	};

	func hasweightd(p : Principal, question : Hash.Hash) : ?Weight {
		let pQ = hashPrincipalQuestion(p, question);
		let weight = do { weights.get(pQ) };
		return weight;
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
							let sourceWeight = weights.get(sourcePQ);
							let testWeight = weights.get(testPQ);
							let commonQuestion : CommonQuestion = {
								question = hash;
								sourceAnswer;
								testAnswer;
								sourceWeight;
								testWeight;
							};
							buf.add(commonQuestion);
						};
					};
				};
			};
		};
		buf.toArray();
	};

	func calcScore(sourceUser : Principal, testUser : Principal) : Float {
		let common = commonQuestions(sourceUser, testUser);
		var score : Int = 0;
		var qScore : Float = 0;
		for (q in Iter.fromArray(common)) {
			score := calcQuestionScore(
				q.sourceAnswer,
				q.testAnswer,
				q.sourceWeight,
				q.testWeight
			);
			//score *= 10; //temp
			//score /= (2 * common.size()); //what is theory or reasoning behind this? check algorithm
			qScore += Float.fromInt(score);
		};
		qScore;
	};

	func changeUserPoints(p : Principal, value : Nat) : () {
		//change into easier way of ?null checking
		let user = switch (users.get(p)) {
			case null return ();
			case (?user) {
				{
					username = user.username;
					created = user.created;
					about = user.about;
					gender = user.gender;
					birth = user.birth;
					connect = user.connect;
					points = value; //nat
				};
			};
		};
		users.put(p, user);
	};

	func changeQuestionPoints(q : Question, value : Int) : () {
		let newQ : Question = {
			created = q.created;
			creater = q.creater;
			question = q.question;
			hash = q.hash;
			color = q.color;
			points = value;
		};
		questions.put(q.hash, newQ);
	};

	//returns user info opt property if not undefined and public viewable
	func checkPublic<T>(prop : (?T, Bool)) : (?T) {
		switch (prop) {
			case (null, _) { null };
			case (?T, false) { null };
			case (?T, true) {
				?T;
			};
		};
	};

	func getXAnsweredQuestions(p : Principal, n : ?Nat) : [Question] {
		let answered = answeredQuestions(p, n);

		func getQuestion(h : Hash.Hash) : ?Question {
			questions.get(h);
		};

		let q = Array.mapFilter(answered, getQuestion);
	};

	//utility functions mostly for filterUsers, could be made more generalized
	func sortByScore(t : (UserWScore), u : (UserWScore)) : Order.Order {
		if (t.1 > u.1) { return #less } else if (t.1 < u.1) { return #greater } else { return #equal };
	};

	func isEq(t : (UserWScore), u : (UserWScore)) : Bool {
		t.1 == u.1;
	};

	// filter users according to parameters
	func filterUsers(p : Principal, f : MatchingFilter) : (UserWScore) {
		let buf = Buffer.Buffer<(UserWScore)>(2);
		var count = 0;
		let callerScore : Float = calcScore(p, p);
		//User Loop
		label ul for (pm in users.keys()) {
			if (users.size() == count) break ul;
			let user = switch (users.get(pm)) {
				case null ();
				case (?user) {
					//Filter Loop
					label fl {
						if (p == pm) { break fl } else {
							//gender
							switch (f.gender) {
								case null ();
								case (Gender) {
									if ((f.gender, true) != user.gender) {
										break fl;
									};
								};
							};
							//age
							switch (user.birth) {
								case (?birth, _) {
									//TODO : make birth-age conversion utility func
									let userAge = birth / (1_000_000_000 * 3600 * 24) / 365;
									//TODO : find way to have em both in if statement , || doesnt work
									if (f.ageRange.0 >= userAge) {
										break fl;
									} else if (f.ageRange.1 <= userAge) {
										break fl;
									};
								};
								case (_)();
							};

							let score : Float = calcScore(p, pm);
							let cohesion = Float.toInt(Float.trunc((score / callerScore) * 100));
							buf.add((pm, cohesion));
						};
					}; //end  fl
				};
			};
			count += 1;
		}; // end ul
		//brute insert the filter target (p can also be anything)
		let cohesionFilter : UserWScore = (p, f.cohesion);
		buf.add(cohesionFilter);
		buf.sort(sortByScore);
		//find index of filter target

		let indexF : ?Nat = Buffer.indexOf(cohesionFilter, buf, isEq);
		let indexM : Nat = switch (indexF) {
			case null { 0 }; //hmm
			case (?i) {
				if (buf.size() == i + 1) { i - 1 } //if last index
				else { i + 1 };
			};
		};

		let match : (UserWScore) = buf.get(indexM); //THIS IS WRONG
		return match;
	};

	// DATA STORAGE

	stable var stableUsers : [(Principal, User)] = [];
	let users = HashMap.fromIter<Principal, User>(Iter.fromArray(stableUsers), 100, Principal.equal, Principal.hash);

	stable var stableQuestions : [(Hash.Hash, Question)] = [];
	let questions = HashMap.fromIter<Hash.Hash, Question>(Iter.fromArray(stableQuestions), 100, Hash.equal, hashhash);

	stable var stableAnswers : [(PrincipalQuestionHash, Answer)] = [];
	let answers = HashMap.fromIter<PrincipalQuestionHash, Answer>(Iter.fromArray(stableAnswers), 100, Hash.equal, hashhash);

	stable var stableWeights : [(PrincipalQuestionHash, Weight)] = [];
	let weights = HashMap.fromIter<PrincipalQuestionHash, Weight>(Iter.fromArray(stableWeights), 100, Hash.equal, hashhash);

	stable var stableSkips : [(PrincipalQuestionHash, Skip)] = [];
	let skips = HashMap.fromIter<PrincipalQuestionHash, Skip>(Iter.fromArray(stableSkips), 100, Hash.equal, hashhash);

	// Upgrade canister
	system func preupgrade() {
		stableUsers := Iter.toArray(users.entries());
		stableQuestions := Iter.toArray(questions.entries());
		stableAnswers := Iter.toArray(answers.entries());
		stableWeights := Iter.toArray(weights.entries());
		stableSkips := Iter.toArray(skips.entries());
	};

	system func postupgrade() {
		stableUsers := [];
		stableQuestions := [];
		stableAnswers := [];
		stableWeights := [];
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
					points = initReward; //nat
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
				//might need to check here for put to be success before awarding points, same for other occurrences
				changeUserPoints(msg.caller, (user.points + createrReward));
			};
		};
		#ok();
	};

	public shared query (msg) func getAskableQuestions(n : Nat) : async Result.Result<[Question], Text> {
		let askables = askableQuestions(msg.caller, n);

		func getQuestion(h : Hash.Hash) : ?Question {
			questions.get(h);
		};

		let q = Array.mapFilter(askables, getQuestion);
		#ok(q);
	};

	public shared query (msg) func getAnsweredQuestions(n : ?Nat) : async Result.Result<[Question], Text> {
		let answered = answeredQuestions(msg.caller, n);

		func getQuestion(h : Hash.Hash) : ?Question {
			questions.get(h);
		};

		let q = Array.mapFilter(answered, getQuestion);
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
		//let user = users.get(msg.caller);
		let user = switch (users.get(msg.caller)) {
			case null return #err("User does not exist");
			case (?user) {
				user;
			};
		};
		changeUserPoints(msg.caller, (user.points + answerReward));
		#ok();
	};

	// // Add a weight
	public shared (msg) func submitWeight(question : Hash.Hash, weight : WeightKind) : async Result.Result<(), Text> {
		let principalQuestion = hashPrincipalQuestion(msg.caller, question);
		let newWeight = {
			user = msg.caller;
			question;
			weight;
		};
		//TEMP : weights.put line is moved to after points check
		//TODO : cleanup and extract possible funcs
		let weightValue : Int = switch (weight) {
			case (#Like(value)) { value };
			case (#Dislike(value)) { - value };
		};
		//get user data
		let user = switch (users.get(msg.caller)) {
			case null return #err("User does not exist");
			case (?user) {
				user;
			};
		};
		//get question data
		let q : Question = switch (questions.get(question)) {
			case null return #err("Question does not exist");
			case (?q) {
				q;
			};
		};
		//check if user has enough points
		if (Nat.less(user.points, Int.abs(weightValue))) {
			return #err("You don't have enough points");
		};
		//let newPoints = Nat.sub(user.points, weightValue);

		weights.put(principalQuestion, newWeight);
		changeUserPoints(msg.caller, (user.points - Int.abs(weightValue)));
		//check if user !== creater
		if (msg.caller != q.creater) {
			switch (users.get(q.creater)) {
				case null {}; //do nothing, creater account might have been removed
				case (?creater) {
					changeUserPoints(q.creater, (creater.points + Int.abs(weightValue)));
				};
			};
		};

		changeQuestionPoints(q, (q.points + weightValue));

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

	//find users based on parameters
	public shared (msg) func findMatch(para : MatchingFilter) : async Result.Result<UserMatch, Text> {
		let user = switch (users.get(msg.caller)) {
			case null return #err("User does not exist");
			case (?user) {
				user;
			};
		};

		if (Nat.less(user.points, queryCost)) {
			return #err("You don't have enough points");
		};

		try {
			changeUserPoints(msg.caller, (user.points - Int.abs(queryCost))); //might other position
			let match : UserWScore = filterUsers(msg.caller, para);
			switch (users.get(match.0)) {
				case null { return #err("Matched user not found!") };
				case (?user) {
					let matchObj : UserMatch = {
						username = user.username;
						about = checkPublic(user.about);
						gender = checkPublic(user.gender);
						birth = checkPublic(user.birth);
						connect = checkPublic(user.connect);
						cohesion = match.1;
						answeredQuestions = getXAnsweredQuestions(match.0, null);
						//TODO : re-enable answeredQuestions
						//also filter first on commonQuestions to add a bool to this array for front-end indicating if both answered
					};
					return #ok(matchObj);
				};
			};
		} catch err {
			return #err("Couldn't filter users and/or deduct points");
		};
	};

};
