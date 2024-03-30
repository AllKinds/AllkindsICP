import User "User";
import Question "Question";
import Principal "mo:base/Principal";
import Configuration "Configuration";
import Result "mo:base/Result";
import Nat8 "mo:base/Nat8";
import Error "Error";
import Array "mo:base/Array";
import Iter "mo:base/Iter";
import Nat "mo:base/Nat";
import Types "Types";

module {

  type Question = Types.Question;
  type QuestionDB = Types.QuestionDB;
  type Answer = Types.Answer;
  type AnswerDB = Types.AnswerDB;
  type SkipDB = Types.SkipDB;
  type AnswerDiff = Types.AnswerDiff;
  type UserDB = Types.UserDB;
  type Result<T> = Types.Result<T>;
  type Error = Error.Error;

  //returnable object of a user that caller requested
  public type UserMatch = {
    user : Types.UserInfo;
    answered : [(Question, AnswerDiff)]; // indicates comparison with caller answer
    uncommon : [Question]; //Questions that user has answered but not caller
    cohesion : Nat8;
    errors : [Error];
  };

  func score(common : [AnswerDiff]) : Result<Nat8> {
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

  public func getUserMatch(users : UserDB, questions : QuestionDB, answers : AnswerDB, skips : SkipDB, userA : Principal, userB : Principal) : Result<UserMatch> {

    let common = Question.getCommon(answers, userA, userB);

    let cohesion = switch (score(common)) {
      case (#ok(s)) s;
      case (#err(e)) return #err(e);
    };

    let ?user = User.getInfo(users, userB) else return #err(#userNotFound);

    let answered = Array.tabulate<(Question, AnswerDiff)>(common.size(), func i = (Question.getQuestion(questions, common[i].question), common[i]));
    let unanswered : Iter.Iter<Question> = Question.unanswered(questions, answers, skips, userA);

    let answersB = Question.getAnswers(answers, userB);
    let uncommon = Iter.filter<Question>(unanswered, func q = Question.has(answersB, q.id));

    let userMatch : UserMatch = {
      user;
      answered; // indicates comparison with caller answer
      uncommon = Iter.toArray(uncommon); // Questions that user has answered but not caller
      cohesion;
      errors = [];
    };

    #ok(userMatch);
  };

};
