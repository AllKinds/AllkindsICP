/// This file contains constants to configure the reward system, pagination and
/// other aspects of the system

module {
  public let rewards = {
    initialPoints : Nat = 100;

    answerReward : Int = 10;
    creatorReward : Int = 50;
    boostReward : Int = -2; // cost per boost point

    queryReward : Int = -10; // ask to find a match
  };

  public let question = {
    minSize : Nat = 5;
    maxSize : Nat = 200;
    maxBoost : Nat = 20;
    skipReward : Int = -3;
    answerReward : Int = 1;
    boostReward : Int = 2;
  };

  public let user = {
    minNameSize = 2;
    maxNameSize = 20;
    maxAge : Nat8 = 120;
  };

  public let matching = {
    minAnswers : Nat = 4; // Users have to answer at least this many questions to start matching or get matched
    minCommonQuestions : Nat = 4; // number of common questions to consider two users for matching
  };

  public let api = {
    maxPageSize : Nat = 500; // number of elements that can be returned in one request
  };

};
