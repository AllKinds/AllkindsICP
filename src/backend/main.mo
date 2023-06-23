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
import Array "mo:base/Array";
import Float "mo:base/Float";
import Order "mo:base/Order";
import None "mo:base/None";
import Cycles "mo:base/ExperimentalCycles";
import Blob "mo:base/Blob";
import Debug "mo:base/Debug";

import T "Types";

actor {

  // CONSTANTS
  let N = 10;
  let initReward : Nat = 2000;
  //!!!! CHANGE init to 100 BEFORE DEPLOY !!!!!
  let answerReward : Nat = 2;
  let createrReward : Nat = 5;
  let queryCost : Nat = 10;
  let minimumQuestionSize : Nat = 5;

  //TYPES INDEX
  type User = T.User;
  type Gender = T.Gender;
  type UserMatch = T.UserMatch;
  type Question = T.Question;
  type Answer = T.Answer;
  type Skip = T.Skip;
  type PrincipalQuestionHash = T.PrincipalQuestionHash;
  type CommonQuestion = T.CommonQuestion;
  type MatchingFilter = T.MatchingFilter;
  type UserWScore = T.UserWScore;
  type FriendStatus = T.FriendStatus;
  type Friend = T.Friend;
  type FriendList = T.FriendList;
  type FriendlyUserMatch = T.FriendlyUserMatch;

  type Hash = Hash.Hash;
  type Result<T, E> = Result.Result<T, E>;

  // UTILITY FUNCTIONS
  func hashQuestion(created : Int, creater : Principal, question : Text) : Hash {
    let t1 = Int.toText(created);
    let t2 = Principal.toText(creater);
    let t3 = question;
    Text.hash(t1 # t2 # t3);
  };

  func hashPrincipalQuestion(p : Principal, questionHash : Hash) : Hash {
    let t1 = Principal.toText(p);
    let t2 = Nat32.toText(questionHash);
    Text.hash(t1 # t2);
  };

  func hashhash(h : Hash) : Hash { h };

  func putQuestion(p : Principal, question : Text, color : Text) : () {
    let created = Time.now();
    let creater = p;
    let hash = hashQuestion(created, creater, question);
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

  func askableQuestions(p : Principal, n : Nat) : [Hash] {
    let buf = Buffer.Buffer<Hash>(16);
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

  func allAnsweredQuestions(p : Principal, n : ?Nat) : [Hash] {
    let buf = Buffer.Buffer<Hash>(16);
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

    func getQuestion(h : Hash) : ?Question {
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
  func hasAnswered(p : Principal, question : Hash) : ?Answer {
    let pQ = hashPrincipalQuestion(p, question);
    answers.get(pQ);
  };

  //make 1 function and specify equal/unequal arg
  func getUnequalQuestions(p : Principal, pm : Principal) : [Question] {
    let pA = getAllAnswered(p, null);
    let pmA = getAllAnswered(pm, null);

    Array.mapFilter<Question, Question>(
      pmA,
      func qm = if (null != Array.find<Question>(pA, func q = (q.hash == qm.hash))) null else ?qm,
    );
  };

  func getEqualQuestions(p : Principal, pm : Principal) : [Question] {
    let pA = getAllAnswered(p, null);
    let pmA = getAllAnswered(pm, null);

    Array.mapFilter<Question, Question>(
      pmA,
      func qm = if (null == Array.find<Question>(pA, func q = (q.hash == qm.hash))) null else ?qm,
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
  // X = a base weight for current simple algorithm making it more balanced
  func calcQScore(source : Answer, test : Answer) : Int {
    let x = 3;
    if (source.answer != test.answer) return 0;
    if (source.weight * test.weight < 0) return 0;
    if (Int.abs(source.weight) <= Int.abs(test.weight)) {
      return Int.abs(source.weight) + x;
    } else {
      return Int.abs(test.weight) + x;
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

  func calcCohesion(pm : Int, p : Int) : Int {
    if (p > pm) {
      if (p * pm == 0) 0 else {
        Float.toInt(
          100 * Float.div(
            Float.fromInt(pm),
            Float.fromInt(p),
          )
        );
      };
    } else {
      100;
    };
  };

  func changeUserPoints(p : Principal, value : Nat) : () {
    let ?user = users.get(p) else return;
    let changedUser = {
      username = user.username;
      created = user.created;
      about = user.about;
      gender = user.gender;
      birth = user.birth;
      connect = user.connect;
      points = value;
      picture = user.picture;
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

  func sortByScore(x : UserWScore, y : UserWScore) : Order.Order {
    if (x.1 < y.1) {
      #less;
    } else if (x.1 > y.1) {
      #greater;
    } else {
      #equal;
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
    Buffer.indexOf<Friend>(search, buf, isEqF);
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
    } else {
      iMa := Nat.add(iCo, 1);
    };
    //TODO : +else -> to also compare bordering values for better result

    return ?buf.get(iMa);
  };

  // DATA STORAGE

  stable var stableUsers : [(Principal, User)] = [];
  let users = HashMap.fromIter<Principal, User>(Iter.fromArray(stableUsers), 100, Principal.equal, Principal.hash);

  stable var stableQuestions : [(Hash, Question)] = [];
  let questions = HashMap.fromIter<Hash, Question>(Iter.fromArray(stableQuestions), 100, Hash.equal, hashhash);

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
  public query ({ caller }) func whoami() : async Principal {
    caller;
  };

  // Create default new user with only a username
  public shared (msg) func createUser(username : Text) : async Result<(), Text> {
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
          about = (null, true);
          gender = (null, true);
          birth = (null, true);
          connect = (null, true);
          points = initReward; //nat
          picture = (null, true);
        };

        // Mutate storage for users data
        friends.put(caller, []);
        users.put(caller, user);
        //friends.put(caller, friendList);
        #ok();
      };
    };
  };

  public shared query (msg) func getUser() : async Result<User, Text> {
    let ?user = users.get(msg.caller) else return #err("User does not exist!");
    #ok(user);
  };

  public shared (msg) func updateProfile(user : User) : async Result<(), Text> {
    if(users.get(msg.caller) == null) return #err("User does not exist!");
    users.put(msg.caller, user);
    #ok();
  };

  public shared (msg) func createQuestion(question : Text, color : Text) : async Result<(), Text> {
    let ?user = users.get(msg.caller) else return #err("User does not exist!");
    if (question.size() < minimumQuestionSize) return #err("Question too short!");
	
    try { putQuestion(msg.caller, question, color) } catch err {
      return #err("Could not create Question!");
    };
    changeUserPoints(msg.caller, (user.points + createrReward));
    #ok();
  };

  public shared query (msg) func getAskableQuestions(n : Nat) : async Result<[Question], Text> {
    let askables = askableQuestions(msg.caller, n);
    func getQuestion(h : Hash) : ?Question {
      questions.get(h);
    };
    let q = Array.mapFilter(askables, getQuestion);
    #ok(q);
  };

  public shared query (msg) func getAnsweredQuestions() : async Result<[Question], Text> {
    let answered = allAnsweredQuestions(msg.caller, null);
    func getQuestion(h : Hash) : ?Question {
      questions.get(h);
    };
    let q = Array.mapFilter(answered, getQuestion);
    #ok(q);
  };

  // Add an answer
  public shared (msg) func submitAnswer(question : Hash, answer : Bool, weight : Int) : async Result<(), Text> {
    let ?user = users.get(msg.caller) else return #err("User does not exist!");
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
  public shared (msg) func submitSkip(question : Hash) : async Result<(), Text> {
    let principalQuestion = hashPrincipalQuestion(msg.caller, question);
    let skip = {
      user = msg.caller;
      question;
    };
    skips.put(principalQuestion, skip);
    #ok();
  };

  //find users based on parameters
  public shared (msg) func findMatch(para : MatchingFilter) : async Result<UserMatch, Text> {
    let ?user = users.get(msg.caller) else return #err("Couldn't get User");
    if (Nat.less(user.points, queryCost)) {
      return #err("You don't have enough points");
    };
    changeUserPoints(msg.caller, (user.points - Int.abs(queryCost)));

    let ?match : ?UserWScore = filterUsers(msg.caller, para) else return #err("Couldn't find any match! Try answering more questions.");
    let ?p = match.0 else return #err("rrreeee");
    let ?userM : ?User = users.get(p) else return #err("Matched user not found!");
    let equalQuestions = getEqualQuestions(msg.caller, p);
    let answered = attachAnswerComparison(msg.caller, p, equalQuestions);
    let uncommon = getUnequalQuestions(msg.caller, p);

    let result : UserMatch = {
      principal = p;
      username = userM.username;
      about = checkPublic(userM.about);
      gender = checkPublic(userM.gender);
      birth = checkPublic(userM.birth);
      connect = checkPublic(userM.connect);
      picture = checkPublic(userM.picture);
      cohesion = match.1;
      answered;
      uncommon;
    };
    return #ok(result);
  };

  //returns both Approved and Unapproved friends
  public shared query (msg) func getFriends() : async Result<([FriendlyUserMatch]), Text> {
    let buf = Buffer.Buffer<FriendlyUserMatch>(16);
    let ?friendList = friends.get(msg.caller) else return #err("You don't have any friends :c ");

    label ul for (f : Friend in friendList.vals()) {
      let p = f.account;
      let ?userM : ?User = users.get(p) else continue ul; //might be that user has been deleted
      let ?status : ?FriendStatus = f.status else return #err("Something went wrong!");
      let cohesion = calcCohesion(
        calcScore(p, msg.caller),
        calcScore(msg.caller, msg.caller),
      );
      let answered = attachAnswerComparison(msg.caller, p, getEqualQuestions(msg.caller, p));
      let uncommon = getUnequalQuestions(msg.caller, p);

      if (status != #Approved) {
        let matchObj : FriendlyUserMatch = {
          principal = p;
          username = userM.username;
          about = checkPublic(userM.about);
          gender = checkPublic(userM.gender);
          birth = checkPublic(userM.birth);
          connect = checkPublic(userM.connect);
          picture = checkPublic(userM.picture);
          cohesion;
          answered;
          uncommon;
          status;

        };
        buf.add(matchObj);
      } else {
        let matchObj : FriendlyUserMatch = {
          principal = p;
          username = userM.username;
          about = userM.about.0;
          gender = userM.gender.0;
          birth = userM.birth.0;
          connect = userM.connect.0;
          picture = userM.picture.0;
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

  public shared (msg) func sendFriendRequest(p : Principal) : async Result<(), Text> {
    let null = getIndexFriend(msg.caller, p) else return #err("User already has a friend status with you.");
    let ?userFriends = friends.get(msg.caller) else return #err("Something went wrong!");
    let ?targetFriends = friends.get(p) else return #err("Something went wrong!");
    let buf = Buffer.fromArray<Friend>(userFriends);
    let targetBuf = Buffer.fromArray<Friend>(targetFriends);

    //give REQ status to new friend of msg.caller friendlist
    let target : Friend = {
      account = p;
      status = ? #Requested;
    };
    let user : Friend = {
      account = msg.caller;
      status = ? #Waiting;
    };

    //updateFriend
    try {
      updateFriend(msg.caller, target, Buffer.toArray(buf));
      updateFriend(p, user, Buffer.toArray(targetBuf));
    } catch err {
      return #err("Failed to update user states");
    };
    #ok();
  };

  public shared (msg) func answerFriendRequest(p : Principal, b : Bool) : async Result<(), Text> {
    let ?userFriends = friends.get(msg.caller) else return #err("Something went wrong!");
    let ?targetFriends = friends.get(p) else return #err("Something went wrong!");
    let buf = Buffer.fromArray<Friend>(userFriends);
    let targetBuf = Buffer.fromArray<Friend>(targetFriends);

    let ?iT = getIndexFriend(p, msg.caller) else return #err("Strange");
    let ?i = getIndexFriend(msg.caller, p) else return #err("You have no friend requests from that user!");
    let friend = buf.get(i) else return #err("Can't check status of your friend");

    switch (friend.status) {
      case (? #Requested) return #err("You already requested this user to connect!");
      case (? #Waiting) {
        let _ = buf.remove(i);
        let _ = targetBuf.remove(iT);
        if (b == false) {
          //rejected
          return #ok();
        };
        //accepted
      };
      case (? #Approved) return #err("You are already friends with this user!");
      case (null) return #err("Strange null");
    };

    var target : Friend = {
      account = p;
      status = ? #Approved;
    };
    let user : Friend = {
      account = msg.caller;
      status = ? #Approved;
    };

    try {
      updateFriend(msg.caller, target, Buffer.toArray(buf));
      updateFriend(p, user, Buffer.toArray(targetBuf));
    } catch err {
      return #err("Failed to update userStates");
    };
    #ok();
  };

};
