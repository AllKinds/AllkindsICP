import Map "mo:map/Map";
import Principal "mo:base/Principal";
import Result "mo:base/Result";
import Text "mo:base/Text";
import Char "mo:base/Char";
import Debug "mo:base/Debug";
import Iter "mo:base/Iter";
import Array "mo:base/Array";
import Nat "mo:base/Nat";
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
    info : TeamInfo;
    invite : Text; // secret to prevent unauthorized users from joining the team
    members : Set<Principal>;
    admins : Set<Principal>;

    questions : QuestionDB;
    answers : AnswerDB;
    skips : SkipDB;
    friends : FriendDB;
  };

  public type TeamInfo = {
    name : Text;
    about : Text;
    logo : Blob;
    listed : Bool;
  };

  public type TeamUserInfo = {
    key : Text;
    info : TeamInfo;
    permissions : Permissions;
    invite : ?Text;
  };

  public type TeamStats = {
    users : Nat;
    questions : Nat;
    answers : Nat;
    connections : Nat;
  };

  public type Permissions = { isMember : Bool; isAdmin : Bool };

  public type TeamDB = Map<Text, Team>;

  let { thash; phash } = Map;

  public func emptyDB() : TeamDB = Map.new<Text, Team>();

  public func create(teams : TeamDB, key : Text, invite : Text, info : TeamInfo, admin : Principal) : Result<TeamInfo> {
    if (Map.has(teams, thash, key)) {
      return #err(#nameNotAvailable);
    };
    if (Text.contains(key, #predicate(func(c) = not (Char.isLowercase(c) and Char.isAlphabetic(c))))) {
      return #err(#validationError);
    };
    let team : Team = {
      info;
      invite;
      members = Set.new();
      admins = Set.make(phash, admin);
      questions = Question.emptyDB();
      answers = Question.emptyAnswerDB();
      skips = Question.emptySkipDB();
      friends = Friend.emptyDB();
    };
    let null = Map.put(teams, thash, key, team) else Debug.trap("Team must not exist");
    return #ok(info);
  };

  public func getStats(teams : TeamDB, key : Text) : Result<TeamStats> {
    let ?team = Map.get(teams, thash, key) else return #err(#teamNotFound);

    let stats : TeamStats = {
      users = Set.size(team.members);
      questions = Question.count(team.questions);
      answers = Question.countAnswers(team.answers);
      connections = Friend.countConnected(team.friends);
    };

    #ok(stats);
  };

  // List all teams a particular user can see
  public func list(teams : TeamDB, user : Principal, known : [Text], showAll : Bool) : Result<[TeamUserInfo]> {
    let all = Map.entries(teams);
    let mapped = Iter.map<(Text, Team), TeamUserInfo>(
      all,
      func((key, x)) {
        let isAdmin = Set.has(x.admins, phash, user);
        let isMember = Set.has(x.members, phash, user);
        return {
          key;
          info = x.info;
          invite = if isAdmin ?x.invite else null;
          permissions = {
            isMember;
            isAdmin;
          };
        };
      },
    );
    let visible = Iter.filter<TeamUserInfo>(
      mapped,
      func({ key; info; permissions }) {
        return (
          showAll //
          or Array.indexOf(key, known, Text.equal) != null //
          or info.listed //
          or permissions.isMember //
          or permissions.isAdmin //
        );
      },
    );
    #ok(Iter.toArray(visible));
  };

  public func get(teams : TeamDB, key : Text, user : Principal) : Result<Team> {
    let ?team = Map.get(teams, thash, key) else return #err(#teamNotFound);
    if (team.info.listed or Set.has(team.members, phash, user)) {
      return #ok(team);
    };
    return #err(#notInTeam);
  };

  public func addMember(teams : TeamDB, key : Text, invite : Text, caller : Principal) : Result<TeamInfo> {
    let ?team = Map.get(teams, thash, key) else return #err(#teamNotFound);

    if (team.invite != invite) { return #err(#invalidInvite) };

    let false = Set.put(team.members, phash, caller) else return #err(#alreadyRegistered);

    #ok(team.info);
  };

  public func removeMember(teams : TeamDB, key : Text, user : Principal) : Result<()> {
    let ?team = Map.get(teams, thash, key) else return #err(#teamNotFound);

    let true = Set.remove(team.members, phash, user) else return #err(#userNotFound);

    #ok;
  };

  public func isAdmin(team : Team, user : Principal) : Bool = Set.has(team.admins, phash, user);
  public func isMember(team : Team, user : Principal) : Bool = Set.has(team.members, phash, user);
  public func getMembers(team : Team) : [Principal] = Set.toArray(team.members);
};
