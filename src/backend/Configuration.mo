/// This file contains constants to configure the reward system, pagination and
/// other aspects of the system

module {
  public let rewards = {
    initialPoints : Nat = 1000;

    answerReward : Int = 2;
    creatorReward : Int = 5;
    boostReward : Int = -2; // cost per boost point

    queryReward : Int = -10; // ask to find a match
  };

  public let question = {
    minSize : Nat = 5;
    maxSize : Nat = 200;
    minimumCommonQuestions : Nat = 5;
    maxBoost : Nat = 10;
  };

  public let user = {
    minNameSize = 2;
    maxNameSize = 20;
  };

  public let matching = {
    minAnswers = 10; // Users have to answer at least this many questions to start matching or get matched
  };

  public let api = {
    maxPageSize = 500; // number of elements that can be returned in one request
  };

};
