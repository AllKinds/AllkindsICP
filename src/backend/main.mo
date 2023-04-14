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
	//TODO : use more hashmap functionality instead of buffers for faster calculations?
	//TODO : maybe make and extract some code to types.mo and utils.mo -> temp broken in moc 0.8?
	//TODO : integrate more variants (point usages, common errors, etc..)
	//TODO : should overall be retyped for more cohesiveness, See type operational expressions

	// CONSTANTS
	let N = 10;
	let initReward : Nat = 10000;
	let answerReward : Nat = 2;
	let createrReward : Nat = 5;
	let queryCost : Nat = 10;

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

	//returnable object of a user that caller requested
	public type UserMatch = {
		principal : Principal;
		username : Text;
		about : ?Text;
		gender : ?Gender;
		birth : ?Int;
		connect : ?Text;
		//TODO: (cohesion : Nat;) changed into int for testing,  should always be between 0-100 so nat8 better
		cohesion : Int;
		answered : [(Question, Bool)]; //bool indicates comparison with caller answer
		uncommon : [Question]; //Questions that user has answered but not caller
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
		answer : Bool;
		weight : Int;
	};

	public type Skip = {
		user : Principal;
		question : Hash.Hash;
	};

	public type PrincipalQuestionHash = Hash.Hash;

	public type CommonQuestion = {
		question : Hash.Hash;
		sourceAnswer : Answer;
		testAnswer : Answer;
	};

	public type MatchingFilter = {
		ageRange : (Nat, Nat);
		gender : ?Gender;
		cohesion : Int;
	};

	public type UserWScore = (?Principal, Int);

	public type FriendStatus = {
		#Requested; //status of requested contact in msg.caller friendlist
		#Waiting; //status of msg.caller in the requested contact friendlist
		#Approved; //status of both users after
		//could be added upon and improved (REQ/WAIT might be too confusing, but this makes it ez to track who requested)
		//maybe change req/wait to send/requests (as its similar to ui)
	};

	//obj instead of tuple , bcs it should be expanded in future
	public type Friend = {
		account : Principal;
		status : ?FriendStatus;
	};

	public type FriendList = [Friend];

	//for viewable data of caller's friends
	public type FriendlyUserMatch = UserMatch and { status : FriendStatus };

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
			if (null == skips.get(pQ)) if (null == answers.get(pQ)) {
				buf.add(hash);
				count += 1;
			};
		};
		Buffer.toArray(buf);
	};

	//TODO : these functions could use renaming as it might seem to be confusing
	func allAnsweredQuestions(p : Principal, n : ?Nat) : [Hash.Hash] {
		let buf = Buffer.Buffer<Hash.Hash>(16);
		var count = 0;
		label f for (hash in questions.keys()) {
			if (n == ?count) break f;
			let pQ = hashPrincipalQuestion(p, hash);
			if (null != answers.get(pQ)) if (null == skips.get(pQ)) {
				buf.add(hash);
				count += 1;
			};
		};
		Buffer.toArray(buf);
	};

	func getAllAnswered(p : Principal, n : ?Nat) : [Question] {
		let answered = allAnsweredQuestions(p, n);

		func getQuestion(h : Hash.Hash) : ?Question {
			questions.get(h);
		};

		let q = Array.mapFilter(answered, getQuestion);
	};

	func attachAnswerComparison(p : Principal, pm : Principal, questions : [Question]) : [(Question, Bool)] {
		func addAnswers(q : Question) : ?(Question, Bool) {
			let pmQ = hashPrincipalQuestion(pm, q.hash);
			let pQ = hashPrincipalQuestion(p, q.hash);
			let ?match : ?Answer = answers.get(pmQ) else return null;
			let user : ?Answer = answers.get(pQ);
			let bool = switch (user) {
				case (null) false;
				case (?user) {
					if (match.answer == user.answer) true else false;
				};
			};
			?(q, bool);
		};

		Array.mapFilter<Question, (Question, Bool)>(questions, addAnswers);
	};

	//unused?
	func hasAnswered(p : Principal, question : Hash.Hash) : ?Answer {
		let pQ = hashPrincipalQuestion(p, question);
		answers.get(pQ);
	};

	//make 1 function and specify equal/unequal arg
	func getUnequalQuestions(p : Principal, pm : Principal) : [Question] {
		let pA = getAllAnswered(p, null);
		let pmA = getAllAnswered(pm, null);

		Array.mapFilter<Question, Question>(
			pmA,
			func qm = if (null == Array.find<Question>(pA, func q = (q.hash != qm.hash))) null else ?qm
		);
	};

	func getEqualQuestions(p : Principal, pm : Principal) : [Question] {
		let pA = getAllAnswered(p, null);
		let pmA = getAllAnswered(pm, null);

		Array.mapFilter<Question, Question>(
			pmA,
			func qm = if (null == Array.find<Question>(pA, func q = (q.hash == qm.hash))) null else ?qm
		);
	};

	func commonQuestions(sourceUser : Principal, testUser : Principal) : [CommonQuestion] {
		let buf = Buffer.Buffer<CommonQuestion>(16);
		label l for (hash in questions.keys()) {
			let sourcePQ = hashPrincipalQuestion(sourceUser, hash);
			let testPQ = hashPrincipalQuestion(testUser, hash);
			//check
			let ?sourceAnswer = answers.get(sourcePQ) else continue l;
			let ?testAnswer = answers.get(testPQ) else continue l;

			//build
			let commonQuestion : CommonQuestion = {
				question = hash;
				sourceAnswer;
				testAnswer;
			};
			buf.add(commonQuestion);
		};
		Buffer.toArray(buf);
	};

	//checks 2 common Q.answers. returns 0 if weight/answers are opposite
	//returns value in weight + 1 that is minimum with both users
	//this ensures that calcScore(caller, caller) is always max score possible
	func calcQScore(source : Answer, test : Answer) : Int {
		if (source.answer != test.answer) return 0;
		if (source.weight * test.weight < 0) return 0;
		if (Int.abs(source.weight) <= Int.abs(test.weight)) {
			return Int.abs(source.weight) + 1;
		} else {
			return Int.abs(test.weight) + 1;
		};
	};

	//calculates a unique score for testUser (match) based on sourceUser (caller)
	func calcScore(sourceUser : Principal, testUser : Principal) : Int {
		let common = commonQuestions(sourceUser, testUser);
		var qScore : Int = 0;

		for (q in Iter.fromArray(common)) {
			qScore += calcQScore(q.sourceAnswer, q.testAnswer);
		};

		qScore;
	};

	//takes 2 unqiue scores and calculates them into % with 'source' as base
	func calcCohesion(pm : Int, p : Int) : Int {
		if (p < pm) {
			if (p * pm == 0) 0 else {
				Float.toInt(
					100 * Float.div(
						Float.fromInt(pm),
						Float.fromInt(p)
					)
				);
			};
		} else {
			100;
		};
	};

	// todo : change into easier way of ?null checking
	func changeUserPoints(p : Principal, value : Nat) : () {
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

	//utility functions mostly for filterUsers
	//could be made more generalized and optimised with switch prob for faster process
	func sortByScore(x : UserWScore, y : UserWScore) : Order.Order {
		if (x.1 < y.1) {
			return #less;
		} else if (x.1 > y.1) {
			return #greater;
		} else {
			return #equal;
		};
	};

	func findCoheFilter(x : UserWScore, y : UserWScore) : Bool {
		x.0 == y.0;
	};

	func isEqF(x : Friend, y : Friend) : Bool {
		x.account == y.account;
	};

	func getIndexFriend(p : Principal, pm : Principal) : ?Nat {
		let ?arr = friends.get(p) else return null;
		let buf = Buffer.fromArray<Friend>(arr);
		let search : Friend = {
			account = pm;
			status = null;
		};
		return Buffer.indexOf<Friend>(search, buf, isEqF);
	};

	func updateFriend(p : Principal, new : Friend, list : FriendList) {
		let buf = Buffer.fromArray<Friend>(list);
		buf.add(new);
		let res = Buffer.toArray(buf);
		friends.put(p, res);
	};

	// filter users according to parameters
	func filterUsers(p : Principal, f : MatchingFilter) : ?UserWScore {
		//TODO : optimize with let-else after 0.8.3 because this is messy
		let buf = Buffer.Buffer<UserWScore>(16);
		var count = 0;
		let callerScore = calcScore(p, p);
		if (callerScore == 0) {
			return null;
		};
		//User Loop
		label ul for (pm : Principal in users.keys()) {
			if (users.size() == count) break ul;
			let ?user = users.get(pm) else continue ul;

			let null = getIndexFriend(p, pm) else continue ul;

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

			let pmScore = calcScore(p, pm);
			let pmCohesion = calcCohesion(pmScore, callerScore);

			if (p != pm) {
				buf.add(?pm, pmCohesion);
			};

			count += 1;
		}; // end ul
		//insert cohesionfilter and sort by <
		buf.add(null, f.cohesion);
		buf.sort(sortByScore);
		let bufSize = buf.size();
		let bufSizeX = Nat.sub(bufSize, 1);
		//find index of cohesion filter
		let ?iCo = Buffer.indexOf((null, f.cohesion), buf, findCoheFilter) else return null;
		var iMa : Nat = 0;
		//returns match index (+1), unless 0 or max
		if (iCo == bufSizeX) {
			iMa := Nat.sub(bufSizeX, 1);
		} else if (iCo == 0) {
			iMa := 1;
		} else {
			iMa := Nat.add(iCo, 1);
		};
		//TODO : +else -> to also compare bordering values for better result

		return ?buf.get(iMa);
	};

	// DATA STORAGE

	stable var stableUsers : [(Principal, User)] = [];
	let users = HashMap.fromIter<Principal, User>(Iter.fromArray(stableUsers), 100, Principal.equal, Principal.hash);

	stable var stableQuestions : [(Hash.Hash, Question)] = [];
	let questions = HashMap.fromIter<Hash.Hash, Question>(Iter.fromArray(stableQuestions), 100, Hash.equal, hashhash);

	stable var stableAnswers : [(PrincipalQuestionHash, Answer)] = [];
	let answers = HashMap.fromIter<PrincipalQuestionHash, Answer>(Iter.fromArray(stableAnswers), 100, Hash.equal, hashhash);

	stable var stableSkips : [(PrincipalQuestionHash, Skip)] = [];
	let skips = HashMap.fromIter<PrincipalQuestionHash, Skip>(Iter.fromArray(stableSkips), 100, Hash.equal, hashhash);

	stable var stableFriends : [(Principal, FriendList)] = [];
	let friends = HashMap.fromIter<Principal, FriendList>(Iter.fromArray(stableFriends), 100, Principal.equal, Principal.hash);

	// Upgrade canister
	system func preupgrade() {
		stableUsers := Iter.toArray(users.entries());
		stableQuestions := Iter.toArray(questions.entries());
		stableAnswers := Iter.toArray(answers.entries());
		stableSkips := Iter.toArray(skips.entries());
		stableFriends := Iter.toArray(friends.entries());
	};

	system func postupgrade() {
		stableUsers := [];
		stableQuestions := [];
		stableAnswers := [];
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
		let ?user = users.get(msg.caller) else return #err("User does not exist!");
		#ok(user);
	};

	public shared (msg) func updateProfile(user : User) : async Result.Result<(), Text> {
		let _ = users.get(msg.caller) else return #err("User does not exist!");
		let _ = users.put(msg.caller, user) else return #err("err");
		#ok();
	};

	public shared (msg) func createQuestion(question : Text) : async Result.Result<(), Text> {
		let ?user = users.get(msg.caller) else return #err("User does not exist!");
		putQuestion(msg.caller, question);
		changeUserPoints(msg.caller, (user.points + createrReward));
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
		let answered = allAnsweredQuestions(msg.caller, n);
		func getQuestion(h : Hash.Hash) : ?Question {
			questions.get(h);
		};
		let q = Array.mapFilter(answered, getQuestion);
		#ok(q);
	};

	// Add an answer
	public shared (msg) func submitAnswer(question : Hash.Hash, answer : Bool, weight : Int) : async Result.Result<(), Text> {
		let ?user = users.get(msg.caller) else return #err("User does not exist!");
		//TODO : check if user has balance to put in weight
		let _ = Nat.less(user.points, Int.abs(weight)) else return #err("You don't have enough points!");

		let principalQuestion = hashPrincipalQuestion(msg.caller, question);
		let newAnswer = {
			user = msg.caller;
			question;
			answer;
			weight;
		};
		answers.put(principalQuestion, newAnswer);
		changeUserPoints(msg.caller, (user.points + answerReward - Int.abs(weight)));
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
		let ?user = users.get(msg.caller) else return #err("Couldn't get User");
		if (Nat.less(user.points, queryCost)) {
			return #err("You don't have enough points");
		};
		changeUserPoints(msg.caller, (user.points - Int.abs(queryCost)));
		//TODO : make generic errors
		let ?match : ?UserWScore = filterUsers(msg.caller, para) else return #err("Couldn't find any match! Try answering more questions.");
		let ?principal = match.0 else return #err("rrreeee");
		let ?userM : ?User = users.get(principal) else return #err("Matched user not found!");
		let equalQuestions = getEqualQuestions(msg.caller, principal);
		let answered = attachAnswerComparison(msg.caller, principal, equalQuestions);
		let uncommon = getUnequalQuestions(msg.caller, principal);

		let result : UserMatch = {
			principal;
			username = userM.username;
			about = checkPublic(userM.about);
			gender = checkPublic(userM.gender);
			birth = checkPublic(userM.birth);
			connect = checkPublic(userM.connect);
			cohesion = match.1;
			answered;
			uncommon;
		}; //TODO : fix above func getXAnsQues, gives literally only answeredQ bcs ongoing bad weight-like-answer implementation
		//also filter first on commonQuestions to add a bool to this array for front-end indicating if both answered
		return #ok(result);
	};

	//TODO : change function w result FriendlyUserMatch (= combined type)
	public shared query (msg) func getFriends() : async Result.Result<([FriendlyUserMatch]), Text> {
		let buf = Buffer.Buffer<FriendlyUserMatch>(16);
		let ?friendList = friends.get(msg.caller) else return #err("You don't have any friends :c ");

		label ul for (f : Friend in friendList.vals()) {
			let principal = f.account;
			let ?userM : ?User = users.get(principal) else continue ul; //might be that user has been deleted
			let ?status : ?FriendStatus = f.status else return #err("Something went wrong!");
			let cohesion = calcCohesion(
				calcScore(principal, msg.caller),
				calcScore(msg.caller, msg.caller)
			);
			let answered = attachAnswerComparison(msg.caller, principal, getEqualQuestions(msg.caller, principal));
			let uncommon = getUnequalQuestions(msg.caller, principal);

			if (status != #Approved) {
				let matchObj : FriendlyUserMatch = {
					principal;
					username = userM.username;
					about = checkPublic(userM.about);
					gender = checkPublic(userM.gender);
					birth = checkPublic(userM.birth);
					connect = checkPublic(userM.connect);
					cohesion;
					answered;
					uncommon;
					status;
				};
				buf.add(matchObj);
			} else {
				let matchObj : FriendlyUserMatch = {
					principal;
					username = userM.username;
					about = userM.about.0;
					gender = userM.gender.0;
					birth = userM.birth.0;
					connect = userM.connect.0;
					cohesion;
					answered;
					uncommon;
					status;
				};
				buf.add(matchObj);
			};

		};
		#ok(Buffer.toArray(buf));
	};

	//TODO : extract reusable function from sendFriendRequest and answerFriendRequest

	public shared (msg) func sendFriendRequest(p : Principal) : async Result.Result<(), Text> {
		let null = getIndexFriend(msg.caller, p) else return #err("User already has a friend status with you.");

		let ?userFriends = friends.get(msg.caller) else return #err("Something went wrong!");
		let ?targetFriends = friends.get(p) else return #err("Something went wrong!");
		let buf = Buffer.fromArray<Friend>(userFriends);
		let targetBuf = Buffer.fromArray<Friend>(targetFriends);

		//updateFriend
		try {
			//give REQ status to new friend of msg.caller

			let target : Friend = {
				account = p;
				status = ?#Requested;
			};
			let user : Friend = {
				account = msg.caller;
				status = ?#Waiting;
			};

			updateFriend(msg.caller, target, Buffer.toArray(buf));
			updateFriend(p, user, Buffer.toArray(targetBuf));

		} catch err {
			return #err("Failed to update user states");
		};
		#ok();
	};

	public shared (msg) func answerFriendRequest(p : Principal, b : Bool) : async Result.Result<(), Text> {
		let ?userFriends = friends.get(msg.caller) else return #err("Something went wrong!");
		let ?targetFriends = friends.get(p) else return #err("Something went wrong!");
		let buf = Buffer.fromArray<Friend>(userFriends);
		let targetBuf = Buffer.fromArray<Friend>(targetFriends);
		let ?iT = getIndexFriend(p, msg.caller) else return #err("Strange");
		let ?i = getIndexFriend(msg.caller, p) else return #err("You have no friend requests from that user!");

		let res : Friend = buf.get(i) else return #err("Can't check status of your friend");

		switch (res.status) {
			case (?#Requested) return #err("You already requested this user to connect!");
			case (?#Waiting) {
				let _ = buf.remove(i);
				let _ = targetBuf.remove(iT);

				if (b == false) {
					//rejected
					return #ok();
				};
				//accepted
			};
			case (?#Approved) return #err("You are already friends with this user!");
			case (null) return #err("Strange null");
		};

		try {
			var target : Friend = {
				account = p;
				status = ?#Approved;
			};
			let user : Friend = {
				account = msg.caller;
				status = ?#Approved;
			};

			updateFriend(msg.caller, target, Buffer.toArray(buf));
			updateFriend(p, user, Buffer.toArray(targetBuf));
			#ok();
		} catch err {
			return #err("Failed to update userStates");
		};

	};

};
