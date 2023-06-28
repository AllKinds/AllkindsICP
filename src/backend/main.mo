import Principal "mo:base/Principal";
import Hash "mo:base/Hash";
import List "mo:base/List";
import HashMap "mo:base/HashMap";
import Int "mo:base/Int";
import Text "mo:base/Text";
import Result "mo:base/Result";
import Time "mo:base/Time";
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

import IterTools "mo:itertools/Iter";

import Question "Question";
import User "User";
import Friend "Friend";
import Matching "Matching";
import Configuration "Configuration";
import Error "Error";
import Iter "mo:base/Iter";

actor {

  //TYPES INDEX
  type User = User.User;
  type Question = Question.Question;
  type Answer = Question.Answer;
  type Skip = Question.Skip;
  type Friend = Friend.Friend;
  type Error = Error.Error;

  type UserDB = User.UserDB;
  type QuestionDB = Question.QuestionDB;
  type AnswerDB = Question.AnswerDB;
  type SkipDB = Question.SkipDB;
  type FriendDB = Friend.FriendDB;
  type MatchingFilter = Matching.MatchingFilter;
  type UserMatch = Matching.UserMatch;

  type Result<T, E> = Result.Result<T, E>;

  // UTILITY FUNCTIONS

  // DATA STORAGE

  stable var users : UserDB = User.emptyDB();

  stable var questions : QuestionDB = Question.emptyDB();

  stable var answers : AnswerDB = Question.emptyAnswerDB();

  stable var skips : SkipDB = Question.emptySkipDB();

  stable var friends : FriendDB = Friend.emptyDB();

  // Upgrade canister
  system func preupgrade() {
    // make sure all data is stored in stable memory
  };

  system func postupgrade() {
    // Cleanup temporary stable data
  };

  // PUBLIC API
  public query ({ caller }) func whoami() : async Principal {
    caller;
  };

  // Create default new user with only a username
  public shared ({ caller }) func createUser(username : Text) : async Result<User, Error> {
    User.add(users, username, caller);
  };

  public shared query ({ caller }) func getUser() : async Result<User, Error> {
    let ?user = User.get(users, caller) else return #err(#notRegistered);
    #ok(user);
  };

  public shared ({ caller }) func updateProfile(user : User) : async Result<User, Error> {
    User.update(users, user, caller);
  };

  public shared ({ caller }) func createQuestion(question : Text, color : Text) : async Result<Question, Error> {
    switch (User.checkFunds(users, #createQuestion, caller)) {
      case (#ok(_)) { /* user has sufficient funds */ };
      case (#err(e)) return #err(e);
    };

    let result = Question.add(questions, question, color, caller);
    let #ok(q) = result else return result;

    let #ok(_) = User.reward(users, #createQuestion, caller) else Debug.trap("Bug: Reward failed. checkFunds should have returned an error already");

    #ok(q);
  };

  public shared query ({ caller }) func getAskableQuestions(limit : Nat) : async [Question] {
    let iter = Question.unanswered(questions, answers, skips, caller);
    let limited = IterTools.take(iter, Nat.min(limit, Configuration.api.maxPageSize));
    Iter.toArray(limited);
  };

  public shared query ({ caller }) func getAnsweredQuestions(limit : Nat) : async [(Question, Answer)] {
    let iter = Question.answered(questions, answers, caller);
    let limited = IterTools.take(iter, Nat.min(limit, Configuration.api.maxPageSize));
    Iter.toArray(limited);
  };

  // Add an answer
  public shared ({ caller }) func submitAnswer(question : Nat, answer : Bool, weight : Nat) : async Result<Answer, Error> {
    let boost = Nat.max(weight, Configuration.question.maxBoost);

    switch (User.checkFunds(users, #createAnswer(boost), caller)) {
      case (#ok(_)) { /* user has sufficient funds */ };
      case (#err(e)) return #err(e);
    };

    let a : Answer = { question; answer; weight = 1 + boost };
    Question.putAnswer(answers, a, caller);

    let #ok(_) = User.reward(users, #createAnswer(boost), caller) else Debug.trap("Bug: Reward failed. checkFunds should have returned an error already");

    #ok(a);
  };

  // Add a skip
  public shared ({ caller }) func submitSkip(question : Nat) : async Result<Skip, Error> {
    let s : Skip = { question; reason = #skip };
    Question.putSkip(skips, s, caller);
    #ok(s);
  };

  //find users based on parameters
  public shared (msg) func findMatch(para : MatchingFilter) : async Result<UserMatch, Error> {
    switch (User.checkFunds(users, #findMatch, caller)) {
      case (#ok(_)) { /* user has sufficient funds */ };
      case (#err(e)) return #err(e);
    };

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

    let #ok(_) = User.reward(users, #findMatch, caller) else Debug.trap("Bug: Reward failed. checkFunds should have returned an error already");

    return #ok(result);
  };

  //returns both Approved and Unapproved friends
  public shared query (msg) func getFriends() : async Result<([UserMatch]), Text> {
    let buf = Buffer.Buffer<UserMatch>(16);
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
    updateFriend(msg.caller, target, Buffer.toArray(buf));
    updateFriend(p, user, Buffer.toArray(targetBuf));
    #ok();
  };

  public shared ({ caller }) func newAnswerFriendRequest(friend : Principal, accept : Bool) : async Result<(), Text> {
    let ?user = users.get(caller) else return #err("User not registerd");
    let ?other = users.get(friend) else return #err("User not registered");
    //User.addFriend(user, friend);
    Debug.trap("not implemented");
  };

  public shared (msg) func oldAnswerFriendRequest(p : Principal, b : Bool) : async Result<(), Text> {
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
        ignore buf.remove(i);
        ignore targetBuf.remove(iT);
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

    updateFriend(msg.caller, target, Buffer.toArray(buf));
    updateFriend(p, user, Buffer.toArray(targetBuf));
    #ok();
  };

};
