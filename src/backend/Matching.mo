import User "User";
import Question "Question";

module {

  type Question = Question.Question;
  type Answer = Question.Answer;
  type AnswerDiff = Question.AnswerDiff;

  public type MatchingFilter = {
    ageRange : (Nat, Nat);
    gender : ?User.Gender;
    cohesion : Nat8;
  };

  //returnable object of a user that caller requested
  public type UserMatch = {
    principal : Principal; // TODO?: should the principal be private?
    user : User.UserInfo;
    answered : [(Question, AnswerDiff)]; // indicates comparison with caller answer
    uncommon : [Question]; //Questions that user has answered but not caller
    cohesion : Nat8;
  };

};
