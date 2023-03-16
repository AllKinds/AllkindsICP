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

actor {

	// CONSTANTS
	let N = 10;
	//TODO : change 'points' to 'reward'
	let initialPoints : Nat = 100;
	let answerPoints : Nat = 2;
	let createrPoints : Nat = 10;
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

	type MatchingFilter = {
		ageRange : (Nat, Nat);
		gender : ?Gender;
		cohesion : Nat;
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

	func putLike(p : Principal, like : Like) : () {
		let pQ = hashPrincipalQuestion(p, like.question);
		likes.put(pQ, like);
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
									count += 1;
								};
								//changing this around could be used to get questions that User has answered
								//or modify function so an extra function parameter could sort on skipped, liked, answered, etc?
								//case null {};
								// case (?_) {
								// 	buf.add(hash);
								// 	count += 1;
								// };
							};
						};
					};
				};
			};
		};
		buf.toArray();
	};

	func answeredQuestions(p : Principal, n : Nat) : [Hash.Hash] {
		let buf = Buffer.Buffer<Hash.Hash>(10);
		var count = 0;
		label f for (hash in questions.keys()) {
			if (n == count) break f;
			let pQ = hashPrincipalQuestion(p, hash);
			switch (skips.get(pQ)) {
				case (?_) {};
				case null {
					switch (likes.get(pQ)) {
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

	// filter users according to parameters
	func filterUsers(p : Principal, filter : MatchingFilter) : [User] {
		let buf = Buffer.Buffer<User>(users.size());
		var count = 0;
		label f for (p2 in users.keys()) {
			if (users.size() == count) break f;
			let user = switch (users.get(p2)) {
				case null ();
				case (?user) {
					//filter msg.caller
					if (p2 != p) {
						//main filters 
						label fp {	

							//gender
							switch (filter.gender) {
								case null ();
								case (Gender) {
									if ((filter.gender, true) != user.gender) {
										break fp;
									};
								};
							};

							//age
							

							buf.add(user);
						}; //end label fp
					};
				};
			};

			count += 1;

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

	//TODO : make function changeUserPoints and changeQuestionPoints

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
			points = q.points + value;
		};
		questions.put(q.hash, newQ);
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
					points = initialPoints; //nat
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
				changeUserPoints(msg.caller, (user.points + createrPoints));
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

	public shared query (msg) func getAnsweredQuestions(n : Nat) : async Result.Result<[Question], Text> {
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
		changeUserPoints(msg.caller, (user.points + answerPoints));
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
		//TEMP : likes.put line is moved to after points check
		//TODO : cleanup and extract possible funcs
		let likeValue : Nat = switch (like) {
			case (#Like(value)) { value };
			case (#Dislike(value)) { value }; //I removed '-' because here it has to be subtracted anyway, maybe like value could be extracted without switch
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
		//conversion to prevent under/over -flow
		//TODO : checkout traps as all these conversions and point check should be done easier
		// let newPoints = Nat32.sub(
		// 	Nat32.fromNat(user.points),
		// 	Nat32.fromNat(queryCost)
		// );
		let userPoints_ : Int32 = Int32.fromNat32(Nat32.fromNat(user.points));
		let likeValue_ : Int32 = Int32.fromNat32(Nat32.fromNat(likeValue));
		let newPoints = userPoints_ - likeValue_;

		if (newPoints >= 0) {
			likes.put(principalQuestion, newLike);
			changeUserPoints(msg.caller, (user.points - likeValue));
			//check if user !== creater
			if (msg.caller != q.creater) {
				switch (users.get(q.creater)) {
					case null {}; //do nothing, creater account might have been removed
					case (?creater) {
						changeUserPoints(q.creater, (creater.points + likeValue));
					};
				};
			};
			let newQuestionPoints : Int = q.points + Int32.toInt(likeValue_);
			changeQuestionPoints(q, newQuestionPoints);
		} else {
			return #err("You don't have enough points");
		};

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
	public shared query (msg) func findMatches(para : MatchingFilter) : async Result.Result<[User], Text> {
		//1. check if user has funds, if not send error
		let user = switch (users.get(msg.caller)) {
			case null return #err("User does not exist");
			case (?user) {
				user;
			};
		};

		let userPoints_ : Int32 = Int32.fromNat32(Nat32.fromNat(user.points));
		let queryCost_ : Int32 = Int32.fromNat32(Nat32.fromNat(queryCost));
		let newPoints = userPoints_ - queryCost_;

		//TODO : maybe Nat.sub could be used in this check statement, test
		if (newPoints >= 0) {

			//let filteredUsers : [User] = filterUsers(para);
			//TEMP : testing out with just gender filter and returning full array

			//2. prepare data
			//3. get all users with filters applied
			//4. calculate msg.caller score w users for something in return

			changeUserPoints(msg.caller, Nat.sub(user.points, queryCost));

			//5. return 2 best
		} else {
			return #err("You don't have enough points");
		};

		//TEMP fix
		let filteredUsers : [User] = filterUsers(msg.caller, para);

		#ok(filteredUsers); //should return array of users
	};

};
