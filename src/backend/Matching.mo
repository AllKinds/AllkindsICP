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
  let { nhash } = Map;

  public type MatchingFilter = {
    ageRange : (Nat, Nat);
    gender : ?User.Gender;
    cohesion : Nat8;
  };

  //returnable object of a user that caller requested
  public type UserMatch = {
    user : User.UserInfo;
    answered : [(Question, AnswerDiff)]; // indicates comparison with caller answer
    uncommon : [Question]; //Questions that user has answered but not caller
    cohesion : Nat8;
  };

  func score(common : [AnswerDiff]) : ?Nat8 {
    if (common.size() < Configuration.question.minCommonQuestions) return null;

    var weights = 0;
    var scores = 0;
    for (diff in common.vals()) {
      weights += diff.weight;
      if (diff.sameAnswer) {
        scores += diff.weight;
      };
    };

    let s = (weights * 100 / scores);
    assert (s <= 100);

    return ?(Nat8.fromIntWrap(s));
  };

  public func getUserMatch(users : UserDB, questions : QuestionDB, answers : AnswerDB, skips : SkipDB, userA : Principal, userB : Principal) : Result<UserMatch, Error> {
    let common = Question.getCommon(answers, userA, userB);
    let answersB = Question.getAnswers(answers, userB);

    let cohesion = score(common);

    let ?fullUser = User.get(users, userB) else return #err(#userNotFound);
    let user = User.filterUserInfo(fullUser);

    let answered = Array.tabulate<(Question, AnswerDiff)>(common.size(), func i = (Question.get(questions, common[i].question), common[i]));
    let unanswered : Iter.Iter<Question> = Question.unanswered(questions, answers, skips, userA);
    let uncommon = Iter.filter<Question>(unanswered, func q = Question.has(answersB, q.id));

    let userMatch : UserMatch = {
      user;
      answered : [(Question, AnswerDiff)]; // indicates comparison with caller answer
      uncommon = Iter.toArray(uncommon); // Questions that user has answered but not caller
      cohesion = Option.get<Nat8>(cohesion, 0); // TODO: handle null
    };

    #ok(userMatch);
  };

};
