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
import Prng "mo:prng";
import Nat64 "mo:base/Nat64";

actor {

  //TYPES INDEX
  type User = User.User;
  type Question = Question.Question;
  type Answer = Question.Answer;
  type Skip = Question.Skip;
  type FriendStatus = Friend.FriendStatus;
  type Error = Error.Error;

  type UserDB = User.UserDB;
  type QuestionDB = Question.QuestionDB;
  type AnswerDB = Question.AnswerDB;
  type SkipDB = Question.SkipDB;
  type FriendDB = Friend.FriendDB;
  type MatchingFilter = Matching.MatchingFilter;
  type UserMatch = Matching.UserMatch;

  type Result<T> = Result.Result<T, Error>;

  // Aliases to get deterministic names for use in frontend code
  type ResultUser = Result<User>;
  type ResultQuestion = Result<Question>;
  type ResultAnswer = Result<Answer>;
  type ResultSkip = Result<Skip>;
  type ResultUserMatch = Result<UserMatch>;
  type ResultUserMatches = Result<[UserMatch]>;

  // UTILITY FUNCTIONS

  // DATA STORAGE

  stable var users : UserDB = User.emptyDB();

  stable var questions : QuestionDB = Question.emptyDB();

  stable var answers : AnswerDB = Question.emptyAnswerDB();

  stable var skips : SkipDB = Question.emptySkipDB();

  stable var friends : FriendDB = Friend.emptyDB();

  var random = Prng.SFC64a(); // insecure random numbers

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
  public shared ({ caller }) func createUser(username : Text) : async ResultUser {
    User.add(users, username, caller);
  };

  public shared query ({ caller }) func getUser() : async ResultUser {
    let ?user = User.get(users, caller) else return #err(#notRegistered);
    #ok(user);
  };

  public shared ({ caller }) func updateProfile(user : User) : async ResultUser {
    User.update(users, user, caller);
  };

  public shared ({ caller }) func createQuestion(question : Text, color : Text) : async ResultQuestion {
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
  public shared ({ caller }) func submitAnswer(question : Nat, answer : Bool, weight : Nat) : async ResultAnswer {
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
  public shared ({ caller }) func submitSkip(question : Nat) : async ResultSkip {
    let s : Skip = { question; reason = #skip };
    Question.putSkip(skips, s, caller);
    #ok(s);
  };

  //find users based on parameters
  public shared ({ caller }) func findMatch(
    ageRange : (Nat, Nat),
    gender : ?User.Gender,
    cohesionRange : (Nat8, Nat8),
  ) : async ResultUserMatch {

    let filter = Matching.createFilter(ageRange, gender, cohesionRange);

    switch (User.checkFunds(users, #findMatch, caller)) {
      case (#ok(_)) { /* user has sufficient funds */ };
      case (#err(e)) return #err(e);
    };

    let userFiltered = User.find(users, filter.users);

    // remove caller and friends
    let withoutSelf = Iter.filter<(Principal, User)>(userFiltered, func(p, u) = p != caller);
    let withoutFriends = Iter.filter<(Principal, User)>(withoutSelf, func(p, u) = Friend.has(friends, caller, p));

    let withScore = IterTools.mapFilter<(Principal, User), UserMatch>(
      withoutFriends,
      func(id, user) = Result.toOption(
        // TODO?: handle errors instead of removing them?
        Matching.getUserMatch(users, questions, answers, skips, caller, id),
      ),
    );

    let scoreFiltered = Iter.filter<UserMatch>(
      withScore,
      func um = (um.cohesion >= filter.cohesion.0) and (um.cohesion <= filter.cohesion.1),
    );

    let matches = Iter.toArray(scoreFiltered);

    if (matches.size() == 0) return #err(#userNotFound);

    let randomIndex = Nat64.toNat(random.next()) % matches.size();

    let result = matches[randomIndex];

    let #ok(_) = User.reward(users, #findMatch, caller) else Debug.trap("Bug: Reward failed. checkFunds should have returned an error already");

    return #ok(result);
  };

  //returns both Approved and Unapproved friends
  public shared query ({ caller }) func getFriends() : async ResultUserMatches {
    let userFriends = Friend.get(friends, caller);

    let filtered = IterTools.mapFilter<(Principal, FriendStatus), UserMatch>(
      userFriends,
      func(p, status) = Result.toOption(
        // TODO?: handle errors instead of removing them?
        Matching.getUserMatch(users, questions, answers, skips, caller, p),
      ),
    );

    #ok(Iter.toArray(filtered));
  };

  /// Send a friend request to a user
  public shared ({ caller }) func sendFriendRequest(username : Text) : async Result<()> {
    let ?id = User.getPrincipal(users, username) else return #err(#userNotFound);
    Friend.request(friends, caller, id);
  };

  public shared ({ caller }) func answerFriendRequest(username : Text, accept : Bool) : async Result<()> {
    let ?id = User.getPrincipal(users, username) else return #err(#userNotFound);
    if (accept) {
      Friend.request(friends, caller, id);
    } else {
      Friend.reject(friends, caller, id);
    };
  };

};
