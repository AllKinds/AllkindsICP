import User "User";
import Question "Question";
import Principal "mo:base/Principal";
import Configuration "Configuration";
import Result "mo:base/Result";
import Nat8 "mo:base/Nat8";
import Error "Error";
import Array "mo:base/Array";
import Iter "mo:base/Iter";
import Map "mo:map/Map";
import Trie "mo:base/Trie";
import Option "mo:base/Option";
import Debug "mo:base/Debug";

module {

  type Question = Question.Question;
  type QuestionDB = Question.QuestionDB;
  type Answer = Question.Answer;
  type AnswerDB = Question.AnswerDB;
  type SkipDB = Question.SkipDB;
  type AnswerDiff = Question.AnswerDiff;
  type UserDB = User.UserDB;
  type Result<T, E> = Result.Result<T, E>;
  type Error = Error.Error;
  type UserFilter = User.UserFilter;
  let { nhash } = Map;

  public type MatchingFilter = {
    users : UserFilter;
    cohesion : Nat8;
  };

  //returnable object of a user that caller requested
  public type UserMatch = {
    user : User.UserInfo;
    answered : [(Question, AnswerDiff)]; // indicates comparison with caller answer
    uncommon : [Question]; //Questions that user has answered but not caller
    cohesion : Nat8;
  };

  public func createFilter(
    minAge : Nat8,
    maxAge : Nat8,
    gender : ?User.Gender,
    cohesion : Nat8,
  ) : MatchingFilter {
    if (cohesion > 100) Debug.trap("Invalid cohesion");

    let users = User.createFilter(minAge, maxAge, gender);
    return { users; cohesion };
  };

  func score(common : [AnswerDiff]) : Result<Nat8, Error> {
    if (common.size() < Configuration.matching.minCommonQuestions) return #err(#notEnoughAnswers);

    var weights : Nat = 0;
    var scores : Nat = 0;
    for (diff in common.vals()) {
      weights += diff.weight;
      if (diff.sameAnswer) {
        scores += diff.weight;
      };
    };

    let s = (scores * 100 / weights);
    assert (s <= 100);

    return #ok(Nat8.fromIntWrap(s));
  };

  public func getUserMatch(users : UserDB, questions : QuestionDB, answers : AnswerDB, skips : SkipDB, userA : Principal, userB : Principal, showNonPublic : Bool) : Result<UserMatch, Error> {

    let common = Question.getCommon(answers, userA, userB);
    let answersB = Question.getAnswers(answers, userB);

    let cohesion = switch (score(common)) {
      case (#ok(s)) s;
      case (#err(e)) return #err(e);
    };

    let ?user = User.getInfo(users, userB, showNonPublic) else return #err(#userNotFound);

    let answered = Array.tabulate<(Question, AnswerDiff)>(common.size(), func i = (Question.get(questions, common[i].question), common[i]));
    let unanswered : Iter.Iter<Question> = Question.unanswered(questions, answers, skips, userA);
    let uncommon = Iter.filter<Question>(unanswered, func q = Question.has(answersB, q.id));

    let userMatch : UserMatch = {
      user;
      answered; // indicates comparison with caller answer
      uncommon = Iter.toArray(uncommon); // Questions that user has answered but not caller
      cohesion;
    };

    #ok(userMatch);
  };

};
