import Hash "mo:base/Hash";
import Principal "mo:base/Principal";
import Text "mo:base/Text";
import Nat32 "mo:base/Nat32";
import Color "Color";
import Time "mo:base/Time";
import TrieMap "mo:base/TrieMap";
import Trie "mo:base/Trie";
import IterTools "mo:itertools/Iter";
import Iter "mo:base/Iter";
import Nat "mo:base/Nat";
import Option "mo:base/Option";
import Map "mo:map/Map";
import Result "mo:base/Result";
import Bool "mo:base/Bool";
import Configuration "Configuration";
import Error "Error";
import BufferHelper "helper/BufferHelper";
import Types "types/Types";
import Buffer "mo:StableBuffer/StableBuffer";

/// Types and functions related to questions and answers
module {

  type Iter<T> = Iter.Iter<T>;
  type Map<K, V> = Map.Map<K, V>;
  type Time = Time.Time;

  type Error = Error.Error;

  type Hash = Hash.Hash;
  type Color = Color.Color;
  type Result<T, E> = Result.Result<T, E>;
  type QuestionDB = Types.QuestionDB;
  type AnswerDB = Types.AnswerDB;
  type SkipDB = Types.SkipDB;
  type StableQuestion = Types.StableQuestion;
  type QuestionID = Types.QuestionID;
  type Answer = Types.Answer;
  type Question = Types.Question;
  type Skip = Types.Skip;
  type QuestionStats = Types.QuestionStats;
  type AnswerDiff = Types.AnswerDiff;
  type UserAnswers = Types.UserAnswers;
  type UserSkips = Types.UserSkips;

  public func emptyDB() : QuestionDB = Buffer.init<StableQuestion>();

  let { phash } = Map;

  public func emptyAnswerDB() : AnswerDB = Map.new<Principal, UserAnswers>();
  public func emptySkipDB() : SkipDB = Map.new<Principal, UserSkips>();

  public func backup(db : QuestionDB) : Iter<StableQuestion> {
    Buffer.vals(db);
  };

  public func backupAnswers(db : AnswerDB) : Iter<(Principal, QuestionID, Answer)> {
    let entries = Map.entries(db);
    let nested = Iter.map<(Principal, UserAnswers), Iter<(Principal, QuestionID, Answer)>>(
      entries,
      func(p, qa) = Iter.map<(QuestionID, Answer), (Principal, QuestionID, Answer)>(
        Trie.iter(qa),
        func(q, a) = (p, q, a),
      ),
    );
    IterTools.flatten(nested);
  };

  public func count(db : QuestionDB) : Nat = Buffer.size(db);

  public func add(db : QuestionDB, question : Text, color : Color, creator : Principal) : Result<Question, Error> {
    let id = Buffer.size(db);
    let result = create(id, question, color, creator);
    let q = switch (result) {
      case (#ok(value)) { value };
      case (#err(error)) { return #err error };
    };

    Buffer.add(db, q);
    #ok(toQuestion(q));
  };

  public func putAnswer(answers : AnswerDB, answer : Answer, user : Principal) : ?Answer {
    let userAnswers = getAnswers(answers, user);

    let (withAnswer, previousAnswer) = Trie.put(userAnswers, key(answer.question), Nat.equal, answer);

    putAnswers(answers, user, withAnswer);

    return previousAnswer;
  };

  public func putSkip(skips : SkipDB, skip : Skip, user : Principal) : ?Skip {
    let userSkips = getSkips(skips, user);

    let (withSkip, previousSkip) = Trie.put(userSkips, key(skip.question), Nat.equal, skip);

    Map.set(skips, phash, user, withSkip);

    return previousSkip;
  };

  func toQuestion(q : StableQuestion) : Question {
    {
      id = q.id;
      created = q.created;
      creator = null;
      question = q.question;
      color = q.color;
      points = q.points;
      deleted = q.hidden;
      category = q.category;
    };
  };

  func toQuestionStats(q : StableQuestion, answers : AnswerDB, skips : SkipDB) : QuestionStats {
    let as = countQuestionAnswers(q.id, answers);
    {
      question = toQuestion(q);
      answers = as.answers;
      yes = as.yes;
      no = as.no;
      skips = countQuestionSkips(q.id, skips);
      boosts = as.boosts;
    };
  };

  func create(id : Nat, question : Text, color : Color, creator : Principal) : Result<StableQuestion, Error> {
    if (question.size() < Configuration.question.minSize) return #err(#tooShort);
    if (question.size() > Configuration.question.maxSize) return #err(#tooLong);

    #ok {
      id;
      created = Time.now();
      creator;
      question;
      color;
      points = 0;
      showCreator = false;
      hidden = false;
      category = "";
    };
  };

  public func get(questions : QuestionDB, id : QuestionID) : StableQuestion {
    Buffer.get(questions, id);
  };

  public func hide(questions : QuestionDB, id : QuestionID, hidden : Bool) {
    let q = Buffer.get(questions, id);
    let new : StableQuestion = {
      id;
      created = q.created;
      creator = q.creator;
      question = q.question;
      color = q.color;
      points = q.points;
      showCreator = q.showCreator;
      hidden; // set hidden
      category = q.category;
    };
    Buffer.put(questions, id, new);
  };

  public func changePoints(questions : QuestionDB, id : QuestionID, pointsDiff : Int) {
    let q = Buffer.get(questions, id);
    let new : StableQuestion = {
      id;
      created = q.created;
      creator = q.creator;
      question = q.question;
      color = q.color;
      points = q.points + pointsDiff; // add points
      showCreator = q.showCreator;
      hidden = q.hidden;
      category = q.category;
    };
    Buffer.put(questions, id, new);
  };

  public func setCategory(questions : QuestionDB, id : QuestionID, category : Text) {
    let q = Buffer.get(questions, id);
    let new : StableQuestion = {
      id;
      created = q.created;
      creator = q.creator;
      question = q.question;
      color = q.color;
      points = q.points;
      showCreator = q.showCreator;
      hidden = q.hidden;
      category; // set category
    };
    Buffer.put(questions, id, new);
  };

  public func getQuestion(questions : QuestionDB, id : QuestionID) : Question {
    toQuestion(Buffer.get(questions, id));
  };

  func compare(answerA : Answer, answerB : Answer) : AnswerDiff {
    assert (answerA.question == answerB.question);
    let sameAnswer = answerA.answer == answerB.answer;

    let weight = answerA.weight * answerB.weight;

    { question = answerA.question; sameAnswer; weight };
  };

  func common(answersA : UserAnswers, answersB : UserAnswers) : [AnswerDiff] {
    let common = Trie.join<Nat, Answer, Answer, AnswerDiff>(answersA, answersB, Nat.equal, compare);
    Trie.toArray<Nat, AnswerDiff, AnswerDiff>(common, func(_, x) = x);
  };

  public func getCommon(answers : AnswerDB, userA : Principal, userB : Principal) : [AnswerDiff] {
    let answersA = getAnswers(answers, userA);
    let answersB = getAnswers(answers, userB);

    common(answersA, answersB);
  };

  public func answered(questions : QuestionDB, answers : AnswerDB, user : Principal) : Iter<(Question, Answer)> {
    let userAnswers = Trie.iter(getAnswers(answers, user));

    // map answers to questions
    let own = Iter.map<(QuestionID, Answer), (Question, Answer)>(
      userAnswers,
      func(q, a) = (toQuestion(Buffer.get(questions, q)), a),
    );

    own;
  };

  public func getByCreator(questions : QuestionDB, user : Principal, showHidden : Bool) : Iter<Question> {
    let all = BufferHelper.valsReverse(questions);
    // filter out deleted questions
    let visable = if (showHidden) all else Iter.filter<StableQuestion>(all, func(q) = not q.hidden);

    let qs = Iter.filter<StableQuestion>(visable, func q = q.creator == user);

    // map answers to questions
    Iter.map<StableQuestion, Question>(
      qs,
      func q = toQuestion(q),
    );
  };

  public func unanswered(questions : QuestionDB, answers : AnswerDB, skips : SkipDB, user : Principal) : Iter<Question> {
    let all = BufferHelper.valsReverse(questions);
    let userAnswers = getAnswers(answers, user);
    let userSkips = getSkips(skips, user);

    // filter out deleted questions
    let visable = Iter.filter<StableQuestion>(all, func(q) = not q.hidden);
    // filter out answered questions
    let withoutAnswered = Iter.filter<StableQuestion>(visable, func q = Trie.get<Nat, Answer>(userAnswers, key(q.id), Nat.equal) == null); // TODO replace func with has()
    // filter out skipped questions
    let withoutSkipped = Iter.filter<StableQuestion>(withoutAnswered, func q = Trie.get<Nat, Skip>(userSkips, key(q.id), Nat.equal) == null);

    let asQuestions = Iter.map<StableQuestion, Question>(withoutSkipped, func q = toQuestion(q));

    asQuestions;
  };

  func key(id : Nat) : Trie.Key<Nat> {
    { hash = Nat32.fromIntWrap(id); key = id };
  };

  /// Get user answers from db.
  /// Returns an empty trie if user has no answers in the db.
  public func getAnswers(answers : AnswerDB, user : Principal) : UserAnswers {
    Option.get(Map.get(answers, phash, user), Trie.empty<Nat, Answer>());
  };

  public func countUserAnswers(answers : AnswerDB, user : Principal) : Nat {
    Trie.size(getAnswers(answers, user));
  };

  public func countAnswers(answers : AnswerDB) : Nat {
    var acc = 0;
    for (byUser in Map.vals(answers)) {
      acc += Trie.size(byUser);
    };
    return acc;
  };

  public func countQuestionAnswers(q : QuestionID, answers : AnswerDB) : {
    answers : Nat;
    yes : Nat;
    no : Nat;
    boosts : Nat;
  } {
    var total = 0;
    var yes = 0;
    var no = 0;
    var boosts = 0;

    for (byUser in Map.vals(answers)) {
      switch (getAnswer(byUser, q)) {
        case (?a) {
          total += 1;
          boosts += a.weight;
          if (a.answer) {
            yes += 1;
          } else {
            no += 1;
          };
        };
        case (null) {};
      };
    };
    return { answers = total; yes; no; boosts };
  };

  public func countQuestionSkips(q : QuestionID, skips : SkipDB) : Nat {
    var total = 0;

    for (byUser in Map.vals(skips)) {
      switch (getSkip(byUser, q)) {
        case (?a) {
          total += 1;
        };
        case (null) {};
      };
    };
    return total;
  };

  public func getQuestionStats(questions : QuestionDB, answers : AnswerDB, skips : SkipDB, showHidden : Bool) : Iter<QuestionStats> {
    let all = BufferHelper.valsReverse(questions);
    let visable = if (showHidden) all else Iter.filter<StableQuestion>(all, func(q) = not q.hidden);

    Iter.map<StableQuestion, QuestionStats>(visable, func q = toQuestionStats(q, answers, skips));
  };

  func putAnswers(answers : AnswerDB, user : Principal, userAnswers : UserAnswers) {
    Map.set(answers, phash, user, userAnswers);
  };

  public func has(answers : UserAnswers, question : QuestionID) : Bool {
    Trie.get<Nat, Answer>(answers, key(question), Nat.equal) != null;
  };

  public func getAnswer(answers : UserAnswers, question : QuestionID) : ?Answer {
    Trie.get<Nat, Answer>(answers, key(question), Nat.equal);
  };

  public func getSkip(skips : UserSkips, question : QuestionID) : ?Skip {
    Trie.get<Nat, Skip>(skips, key(question), Nat.equal);
  };

  /// Get user skips from db.
  /// Returns an empty trie if user has no answers in the db.
  func getSkips(answers : SkipDB, user : Principal) : UserSkips {
    Option.get(Map.get(answers, phash, user), Trie.empty<Nat, Skip>());
  };

};
