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
	//TODO : copy and remake functions with moc 8.3 (check also .4 and .5) additions
	//TODO : use more hashmap functionality instead of buffers for faster calculations
	//TODO : maybe make and extract some code to types.mo and utils.mo
	//TODO : integrate more variants (point usages, common errors, etc..)
	//TODO : should overall be retyped for more cohersiveness, See type operational expressions

	// CONSTANTS
	let N = 10;
	//TODO : change 'points' to 'reward'
	let initReward : Nat = 10000;
	let answerReward : Nat = 2;
	let createrReward : Nat = 10;
	let queryCost : Nat = 30;

	//DATA TYPES

	public type User = {
		username : Text;
		created : Int;
		about : (?Text, Bool);
		gender : (?Gender, Bool);
		birth : (?Int, Bool);
		connect : (?Text, Bool); //= email or social media link
		points : Nat; //Nat bcs user points should not go negative
	};

	public type UserMatch = {
		principal : Principal;
		username : Text;
		about : ?Text;
		gender : ?Gender;
		birth : ?Int;
		connect : ?Text;
		//TODO: (cohesion : Nat;) changed into int for testing,  should always be between 0-100 so nat8 better
		cohesion : Int;
		answeredQuestions : [Question];
	};

	public type Gender = {
		#Male;
		#Female;
		#Queer;
		#Other;
	};

	// Color indicates optional background color for the question
	public type Question = {
		created : Int;
		creater : Principal;
		question : Text;
		hash : Hash.Hash;
		color : ?Color;
		points : Int; //int bcs question points should be able to go negative
	};

	// Only one color for now
	public type Color = {
		#Default;
	};

	public type Answer = {
		user : Principal;
		question : Hash.Hash;
		answer : AnswerKind;
	};

	public type Weight = {
		user : Principal;
		question : Hash.Hash;
		weight : WeightKind; //this would need to become an Int
	};

	public type Skip = {
		user : Principal;
		question : Hash.Hash;
	};

	// Only one answer type for now
	public type AnswerKind = {
		#Bool : Bool;
	};

	// Nat indicates a possible amount of tokens / points appointed by the user to to the question
	public type WeightKind = {
		//this would need to be removed
		#Like : Nat;
		#Dislike : Nat;
	};

	public type PrincipalQuestionHash = Hash.Hash;

	public type CommonQuestion = {
		question : Hash.Hash;
		sourceAnswer : Answer;
		testAnswer : Answer;
		sourceWeight : ?Weight;
		testWeight : ?Weight;
	};

	public type MatchingFilter = {
		ageRange : (Nat, Nat);
		gender : ?Gender;
		cohesion : Int;
	};

	//gotta rewrite this arrays prob will be very bad and broken
	public type UserWScore = (?Principal, Int);

	public type FriendStatus = {
		#Requested; //status of user that received request
		#Waiting; //status of user that send request
		#Approved; //status of both users after
	};

	//obj instead of tuple , bcs it should be expanded in future
	public type Friend = {
		account : Principal;
		status : ?FriendStatus;
	};

	public type FriendList = [Friend];

	//for viewable data of caller's friends
	public type FriendlyUserMatch = UserMatch and Friend;

	// UTILITY FUNCTIONS

	//create hashmaps for friends stuff

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
		let buf = Buffer.Buffer<Hash.Hash>(16);
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
		let buf = Buffer.Buffer<Hash.Hash>(16);
		var count = 0;
		label f for (hash in questions.keys()) {
			if (n == ?count) break f;
			let pQ = hashPrincipalQuestion(p, hash);
			if (null == skips.get(pQ)) if (null == weights.get(pQ)) if (null != answers.get(pQ)) {
				buf.add(hash);
				count += 1;
			};
		};
		buf.toArray();
	};

	// calc score for 2 answers and optional 2 weights
	//TODO : optimise with let-alse after 0.8.3 and change accordingly after Weight type is revamped
	func calcQuestionScore(sourceAnswer : Answer, testAnswer : Answer, sourceWeight : ?Weight, testWeight : ?Weight) : Int {
		assert (sourceAnswer.question == testAnswer.question);
		// let hasWeights = Option.isSome(sourceWeight) and Option.isSome(testWeight);
		// let hasNoWeights = Option.isNull(sourceWeight) and Option.isNull(testWeight);
		let compareAnswers : Bool = sourceAnswer.answer == testAnswer.answer;
		//let compareWeights : Bool = ...

		if (compareAnswers == false) {
			//also check for weights here
			return 0;
		} else {
			// let sourceAnswerScore : Int = if (sourceAnswer.answer == #Bool(true)) { 1 } else { -1 };
			// let testAnswerScore : Int = if (testAnswer.answer == #Bool(true)) { 1 } else { -1 };
			let sourceWeightScore : Int = switch (sourceWeight) {
				case (?sourceWeight) {
					switch (sourceWeight.weight) {
						case (#Like(score)) { score };
						case (#Dislike(score)) { score };
					};
				};
				case null { 0 };
			};

			let testWeightScore : Int = switch (testWeight) {
				case (?testWeight) {
					switch (testWeight.weight) {
						case (#Like(score)) { score };
						case (#Dislike(score)) { score };
					};
				};
				case null { 0 };
			};

			var wScore : Int = 1; //temp ugly fix
			//rework this: 1) both negative weight should then become positive and added
			// 2) negative and positive weight could make only count negative (seems logical)

			//init score with 1 so people can match even if they didnt weigh but still answered the same

			// if (sourceWeightScore >= 0 and testWeightScore >= 0) {
			// 	wScore += sourceWeightScore + testWeightScore;
			// };
			// if (sourceWeightScore <= 0 and testWeightScore <= 0) {
			// 	wScore += sourceWeightScore + testWeightScore;
			// };
			// if (sourceWeightScore == 0 and testWeightScore == 0) {
			// 	wScore += sourceWeightScore + testWeightScore;
			// };
			wScore += sourceWeightScore + testWeightScore;
			return wScore;
		};
	};

	func hasAnswered(p : Principal, question : Hash.Hash) : ?Answer {
		let pQ = hashPrincipalQuestion(p, question);
		return answers.get(pQ);
	};

	func hasweightd(p : Principal, question : Hash.Hash) : ?Weight {
		let pQ = hashPrincipalQuestion(p, question);
		return weights.get(pQ);
	};

	func commonQuestions(sourceUser : Principal, testUser : Principal) : [CommonQuestion] {
		let buf = Buffer.Buffer<CommonQuestion>(16);
		label l for (hash in questions.keys()) {
			let sourcePQ = hashPrincipalQuestion(sourceUser, hash);
			let testPQ = hashPrincipalQuestion(testUser, hash);
			//check
			let ?sourceAnswer = answers.get(sourcePQ) else continue l;
			let ?testAnswer = answers.get(testPQ) else continue l;
			let sourceWeight = weights.get(sourcePQ);
			let testWeight = weights.get(testPQ);
			//build
			let commonQuestion : CommonQuestion = {
				question = hash;
				sourceAnswer;
				testAnswer;
				sourceWeight;
				testWeight;
			};
			buf.add(commonQuestion);
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
			//score /= (2 * common.size());
			//Algorithm calc needs heavy revamp, but atleast its now giving a more normal value
			qScore += Float.fromInt(score);
		};
		qScore;
	};

	func changeUserPoints(p : Principal, value : Nat) : () {
		//change into easier way of ?null checking
		let ?user = users.get(p) else return;
		let changedUser = {
			username = user.username;
			created = user.created;
			about = user.about;
			gender = user.gender;
			birth = user.birth;
			connect = user.connect;
			points = value; //nat
		};
		users.put(p, changedUser);
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

	//utility functions mostly for filterUsers
	//could be made more generalized and optimised with switch prob for faster process
	func sortByScore(t : UserWScore, u : UserWScore) : Order.Order {
		if (t.1 < u.1) {
			return #less;
		} else if (t.1 > u.1) {
			return #greater;
		} else {
			return #equal;
		};
	};

	func findCoheFilter(t : UserWScore, u : UserWScore) : Bool {
		t.0 == u.0;
	};

	// filter users according to parameters
	func filterUsers(p : Principal, f : MatchingFilter) : ?UserWScore {
		//TODO : optimize with let-else after 0.8.3 because this is messy
		let buf = Buffer.Buffer<(UserWScore)>(16);
		var count = 0;
		let callerScore : Float = calcScore(p, p);
		Debug.print(debug_show ("callerScore", callerScore));
		Debug.print(debug_show ("userPrinciple", p));
		//User Loop
		label ul for (pm : Principal in users.keys()) {
			if (users.size() == count) break ul;
			switch (users.get(pm)) {
				case null ();
				case (?user) {
					//gender
					switch (f.gender) {
						case null ();
						case (Gender) {
							if ((f.gender, true) != user.gender) {
								continue ul;
							};
						};
					};
					//age
					switch (user.birth) {
						case (?birth, _) {
							//TODO : make birth-age conversion utility func
							let userAge = birth / (1_000_000_000 * 3600 * 24) / 365;
							if ((f.ageRange.0 >= userAge) or (f.ageRange.1 <= userAge)) {
								continue ul;
							};
						};
						case (_)();
					};

					let pmScore : Float = calcScore(p, pm);
					let pmCohesion = Float.toInt(Float.trunc((pmScore / callerScore) * 100));
					//maybe fix: check here if user is itself, and if so add cohesion filter to username to solve 2 bugs
					if (p == pm) {

					} else {
						buf.add(?pm, pmCohesion);
					};
				};
			};
			count += 1;
		}; // end ul

		//let newBuf = Buffer.Buffer<(UserWScore)>(16);
		//buf.filterEntries(func(_, (x, y)) = x != p); //TEMP : testing if this does remove principal entries

		//insert filters and sort by <
		buf.add(null, f.cohesion);
		Debug.print(debug_show ("f.cohesion", f.cohesion));
		buf.sort(sortByScore);
		let bufSize = buf.size();
		//find index of filter target
		let ?iCo = Buffer.indexOf((null, f.cohesion), buf, findCoheFilter) else return null;
		//takes next Index in score before f.cohesion unless end or start of buf
		let iMa : Nat = switch (iCo) {
			case 0 Nat.add(iCo, 1);
			case _ Nat.sub(iCo, 1);
		};
		// Debug.print(debug_show ("IndexFilter : ", iCo));
		Debug.print(debug_show ("IndexCohesion : ", iCo));
		Debug.print(debug_show ("IndexMatch : ", iMa));
		let clone = Buffer.clone(buf); //temp test
		Debug.print(debug_show ("arr:", clone.toArray()));
		let resultMatch = buf.get(iMa);
		//Debug.print(debug_show ("arr:", buf.toArray()));

		return ?resultMatch;

	};

	func isEqF(x : Friend, y : Friend) : Bool {
		x.account == y.account;
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

	stable var stableFriends : [(Principal, FriendList)] = [];
	let friends = HashMap.fromIter<Principal, FriendList>(Iter.fromArray(stableFriends), 100, Principal.equal, Principal.hash);

	// Upgrade canister
	system func preupgrade() {
		stableUsers := Iter.toArray(users.entries());
		stableQuestions := Iter.toArray(questions.entries());
		stableAnswers := Iter.toArray(answers.entries());
		stableWeights := Iter.toArray(weights.entries());
		stableSkips := Iter.toArray(skips.entries());
		stableFriends := Iter.toArray(friends.entries());
	};

	system func postupgrade() {
		stableUsers := [];
		stableQuestions := [];
		stableAnswers := [];
		stableWeights := [];
		stableSkips := [];
		stableFriends := [];
	};

	// PUBLIC API

	// Create default new user with only a username
	public shared (msg) func createUser(username : Text) : async Result.Result<(), Text> {
		let caller = msg.caller;
		let created = Time.now();
		let friendList = List.nil();
		//TODO : optimise with let-else after 0.8.3
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
				friends.put(caller, []);
				users.put(caller, user);
				//friends.put(caller, friendList);
				#ok();
			};
		};
	};

	public shared query (msg) func getUser() : async Result.Result<User, Text> {
		switch (users.get(msg.caller)) {
			case (?user) return #ok(user);
			case null return #err("User does not exist!");
		};
		//TODO : optimise with let-else after 0.8.3
	};

	public shared (msg) func updateProfile(user : User) : async Result.Result<(), Text> {
		switch (users.get(msg.caller)) {
			case null { return #err("User does not exist!") };
			case (?_) {
				users.put(msg.caller, user);
			};
		};
		#ok();
		//TODO : optimise with let-else after 0.8.3
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
		//TODO : optimise with let-else after 0.8.3
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

		//TODO : optimise with let-else after 0.8.3
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
		//TODO : optimise with let-else after 0.8.3
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
		let ?user = users.get(msg.caller) else return #err("");

		if (Nat.less(user.points, queryCost)) {
			return #err("You don't have enough points");
		};
		changeUserPoints(msg.caller, (user.points - Int.abs(queryCost)));

		//TODO : make generic errors
		let ?match : ?UserWScore = filterUsers(msg.caller, para) else return #err("Couldn't find any match!");
		let ?principalMatch = match.0 else return #err("rrreeee");
		let ?userM : ?User = users.get(principalMatch) else return #err("Matched user not found!");

		return #ok(
			{
				principal = principalMatch;
				username = userM.username;
				about = checkPublic(userM.about);
				gender = checkPublic(userM.gender);
				birth = checkPublic(userM.birth);
				connect = checkPublic(userM.connect);
				cohesion = match.1;
				answeredQuestions = getXAnsweredQuestions(principalMatch, null);
				//TODO : fix above func getXAnsQues, gives literally only answeredQ bcs ongoing bad weight-like-answer implementation
				//also filter first on commonQuestions to add a bool to this array for front-end indicating if both answered
			} : UserMatch
		);
	};

	public shared query (msg) func getFriends() : async Result.Result<([Friend]), Text> {
		let ?friendList = friends.get(msg.caller) else return #err("Something went wrong!");
		#ok(friendList);
	};

	public shared (msg) func sendFriendRequest(p : Principal) : async Result.Result<(), Text> {
		let ?user = users.get(msg.caller) else return #err("You are not registered!");
		let ?userFriends = friends.get(msg.caller) else return #err("Something went wrong!");
		let ?targetFriends = friends.get(p) else return #err("Something went wrong!");
		let buf = Buffer.fromArray<Friend>(userFriends);
		let search : Friend = {
			account = p;
			status = null;
		};
		switch (Buffer.indexOf<Friend>(search, buf, isEqF)) {
			case (null) {};
			case (?i) {
				let res : Friend = buf.get(i) else return #err("Can't check status of your friend");
				switch (res.status) {
					case (?#Requested) return #err("You already requested this user to connect!");
					case (?#Waiting) return #err("You already have a pending connection request from this user!");
					case (?#Approved) return #err("You are already friends with this user!");
					case (null) return #err("Strange");
				};
			};
		};

		// let res = buf.get(index);
		// let ?status = res.status else return #err("Something went wrong! Friend status not found.");
		// let a = status == #Requested else return #err("You already requested this user to connect!");
		// let b = status == #Waiting else return #err("You already have a pending connection request from this user!");
		// let c = status == #Approved else return #err("You are already friends with this user!");
		//fix to let ?_ =
		try {
			let newFriend : Friend = {
				account = p;
				status = ?#Requested;
			};
			buf.add(newFriend);
			let arr = Buffer.toArray(buf);
			friends.put(msg.caller, arr);

			//change targetUser friend array w caller
			let userFriend : Friend = {
				account = msg.caller;
				status = ?#Waiting;
			}; //no need for checks as they logically wouldn't happen here normally
			let targetBuf = Buffer.fromArray<Friend>(targetFriends);
			targetBuf.add(userFriend);
			let targetArr = Buffer.toArray(buf);
			friends.put(p, targetArr);
		} catch err {
			return #err("Failed to update userStates");
		};
		#ok();
	};

	public shared (msg) func answerFriendRequest(p : Principal, b : Bool) : async Result.Result<(), Text> {
		let ?user = users.get(msg.caller) else return #err("You are not registered!");
		let ?userFriends = friends.get(msg.caller) else return #err("Something went wrong!");
		let ?targetFriends = friends.get(p) else return #err("Something went wrong!");
		let buf = Buffer.fromArray<Friend>(userFriends);
		var friend : Friend = {
			account = p;
			status = ?#Approved;
		};
		var newStatus : ?FriendStatus = null;
		switch (Buffer.indexOf<Friend>(friend, buf, isEqF)) {
			case (null) { return #err("You have no friend requests from that user!") };
			case (?i) {
				let res : Friend = buf.get(i) else return #err("Can't check status of your friend");
				switch (res.status) {
					case (?#Requested) return #err("You already requested this user to connect!");
					case (?#Waiting) {
						if (b == false) {
							let _ = buf.remove(i);
						};
					};
					case (?#Approved) return #err("You are already friends with this user!");
					case (null) return #err("Strange");
				};
			};
		};
		try {
			//put array back
			let arr = Buffer.toArray(buf);
			friends.put(msg.caller, arr);

			//change your own friendstatus on your friend's list
			let userFriend : Friend = {
				account = msg.caller;
				status = ?#Approved;
			};
			let targetBuf = Buffer.fromArray<Friend>(targetFriends);
			targetBuf.add(userFriend);
			let targetArr = Buffer.toArray(buf);
			friends.put(p, targetArr);
		} catch err {
			return #err("Failed to update userStates");
		};

		#ok();
	};

};
