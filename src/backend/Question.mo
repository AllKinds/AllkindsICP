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
import Buffer "mo:StableBuffer/StableBuffer";
import Map "mo:map/Map";
import Result "mo:base/Result";
import Configuration "Configuration";
import Error "Error";

/// Types and functionst related to questions and answers
module {

  type Iter<T> = Iter.Iter<T>;
  type Map<K, V> = Map.Map<K, V>;
  type Time = Time.Time;
  public type QuestionID = Nat;
  type Buffer<T> = Buffer.StableBuffer<T>;

  public type QuestionDB = Buffer<Question>;
  public type UserAnswers = Trie.Trie<QuestionID, Answer>;
  public type UserSkips = Trie.Trie<QuestionID, Skip>;
  public type AnswerDB = Map<Principal, UserAnswers>;
  public type SkipDB = Map<Principal, UserSkips>;

  // Color indicates optional background color for the question
  public type Question = {
    id : QuestionID;
    created : Time;
    creator : Principal;
    question : Text;
    color : Text;
    points : Int; // type Int because question points should be able to go negative
  };

  public type Answer = {
    question : Nat; // Question ID // TODO? remove because it can be implied by the key in UserAnswers?
    answer : Bool;
    weight : Nat;
  };

  public type Skip = {
    question : Nat; // Question ID // TODO? remove because it can be implied by the key in UserAnswers?
    reason : { #skip; #flag };
  };

  public type AnswerDiff = {
    question : Nat;
    sameAnswer : Bool;
    weight : Nat;
  };

  public type Dismissed = {
    question : Nat;
  };

  type Error = Error.Error;

  type Hash = Hash.Hash;
  type Color = Color.Color;
  type Result<T, E> = Result.Result<T, E>;

  public func emptyDB() : QuestionDB = Buffer.init<Question>();

  let { phash } = Map;

  public func emptyAnswerDB() : AnswerDB = Map.new<Principal, UserAnswers>(phash);
  public func emptySkipDB() : SkipDB = Map.new<Principal, UserSkips>(phash);

  public func backup(db : QuestionDB) : Iter<Question> {
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

  public func add(db : QuestionDB, question : Text, color : Color, creator : Principal) : Result<Question, Error> {
    let id = Buffer.size(db);
    let result = create(id, question, color, creator);
    let #ok(q) = result else return result;

    Buffer.add(db, q);
    result;
  };

  public func putAnswer(answers : AnswerDB, answer : Answer, user : Principal) : () {
    let userAnswers = getAnswers(answers, user);

    let (withAnswer, previousAnswer) = Trie.put(userAnswers, key(answer.question), Nat.equal, answer);

    putAnswers(answers, user, withAnswer);
  };

  public func putSkip(skips : SkipDB, skip : Skip, user : Principal) : () {
    let userSkips = getSkips(skips, user);

    let (withSkip, previousSkip) = Trie.put(userSkips, key(skip.question), Nat.equal, skip);

    Map.set(skips, phash, user, withSkip);
  };

  func create(id : Nat, question : Text, color : Color, creator : Principal) : Result<Question, Error> {
    if (question.size() < Configuration.question.minSize) return #err(#tooShort);
    if (question.size() > Configuration.question.maxSize) return #err(#tooLong);

    #ok {
      id;
      created = Time.now();
      creator;
      question;
      color;
      points = 0;
    };
  };

  public func get(questions : QuestionDB, id : QuestionID) : Question {
    Buffer.get(questions, id);
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
    Iter.map<(QuestionID, Answer), (Question, Answer)>(
      userAnswers,
      func(q, a) = (Buffer.get(questions, q), a),
    );
  };

  public func unanswered(questions : QuestionDB, answers : AnswerDB, skips : SkipDB, user : Principal) : Iter<Question> {
    let all = Buffer.vals(questions);
    let userAnswers = getAnswers(answers, user);
    let userSkips = getSkips(skips, user);

    // filter out answered questions
    let withoutAnswered = Iter.filter<Question>(all, func q = Trie.get<Nat, Answer>(userAnswers, key(q.id), Nat.equal) == null); // TODO replace func with has()
    // filter out skipped questions
    let withoutSkipped = Iter.filter<Question>(withoutAnswered, func q = Trie.get<Nat, Skip>(userSkips, key(q.id), Nat.equal) == null);

    withoutSkipped;
  };

  func key(id : Nat) : Trie.Key<Nat> {
    { hash = Nat32.fromIntWrap(id); key = id };
  };

  /// Get user answers from db.
  /// Returns an empty trie if user has no answers in the db.
  public func getAnswers(answers : AnswerDB, user : Principal) : UserAnswers {
    Option.get(Map.get(answers, phash, user), Trie.empty<Nat, Answer>());
  };

  func putAnswers(answers : AnswerDB, user : Principal, userAnswers : UserAnswers) {
    Map.set(answers, phash, user, userAnswers);
  };

  public func has(answers : UserAnswers, question : QuestionID) : Bool {
    Trie.get<Nat, Answer>(answers, key(question), Nat.equal) != null;
  };

  /// Get user skips from db.
  /// Returns an empty trie if user has no answers in the db.
  func getSkips(answers : SkipDB, user : Principal) : UserSkips {
    Option.get(Map.get(answers, phash, user), Trie.empty<Nat, Skip>());
  };

};
