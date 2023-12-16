import Map "mo:map/Map";
import Principal "mo:base/Principal";
import Result "mo:base/Result";
import Set "mo:map/Set";
import Question "Question";
import User "User";
import Friend "Friend";
import Matching "Matching";
import Error "Error";

module {
  type Map<K, V> = Map.Map<K, V>;
  type Set<T> = Set.Set<T>;

  type UserDB = User.UserDB;
  type QuestionDB = Question.QuestionDB;
  type AnswerDB = Question.AnswerDB;
  type SkipDB = Question.SkipDB;
  type FriendDB = Friend.FriendDB;
  type Error = Error.Error;
  type Result<T> = Result.Result<T, Error>;

  public type Team = {
    name : Text;
    invite : Text;
    logo : Blob;
    listed : Bool;
    members : Set<Principal>;

    questions : QuestionDB;
    answers : AnswerDB;
    skips : SkipDB;
    friends : FriendDB;
    teams : TeamDB;
  };

  public type TeamDB = Map<Text, Team>;

  let { thash; phash } = Map;

  public func emptyDB() : TeamDB = Map.new<Text, Team>(thash);

  public func create(teams : TeamDB, key : Text) : Result<()> {
    return #err(#nameNotAvailable);
  };

  public func get(teams : TeamDB, key : Text, user : Principal) : Result<Team> {
    let ?team = Map.get(teams, thash, key) else return #err(#notInTeam);
    if (Set.has(team.members, phash, user)) {
      return #ok(team);
    };
    return #err(#notInTeam);
  };
};
