import Map "mo:map/Map";
import Principal "mo:base/Principal";
import Result "mo:base/Result";
import Text "mo:base/Text";
import Char "mo:base/Char";
import Debug "mo:base/Debug";
import Iter "mo:base/Iter";
import Array "mo:base/Array";
import Nat32 "mo:base/Nat32";
import Set "mo:map/Set";
import Question "Question";
import Friend "Friend";
import Error "Error";
import Types "types/Types";
import Prng "mo:prng";

module {
  type Map<K, V> = Map.Map<K, V>;
  type Set<T> = Set.Set<T>;

  type UserDB = Types.UserDB;
  type QuestionDB = Types.QuestionDB;
  type AnswerDB = Types.AnswerDB;
  type SkipDB = Types.SkipDB;
  type FriendDB = Types.FriendDB;
  type Error = Error.Error;
  type Result<T> = Types.Result<T>;
  type Team = Types.Team;
  type TeamDB = Types.TeamDB;
  type TeamInfo = Types.TeamInfo;
  type TeamStats = Types.TeamStats;
  type TeamUserInfo = Types.TeamUserInfo;
  type TeamUserSettingsDB = Types.TeamUserSettingsDB;

  let { thash; phash } = Map;

  public func create(teams : TeamDB, key : Text, invite : Text, info : TeamInfo, admin : Principal) : Result<TeamInfo> {
    if (Map.has(teams, thash, key)) {
      return #err(#nameNotAvailable);
    };
    if (Text.contains(key, #predicate(func(c) = not (Char.isLowercase(c) and Char.isAlphabetic(c))))) {
      return #err(#validationError);
    };
    if (key == "") {
      return #err(#validationError);
    };
    if (info.name == "") { return #err(#validationError) };
    if (info.name.size() > 42) { return #err(#tooLong) };
    if (info.about.size() > 512) { return #err(#tooLong) };
    let team : Team = {
      info;
      invite;
      userInvites = Map.new();
      members = Set.new();
      admins = Set.make(phash, admin);
      questions = Question.emptyDB();
      answers = Question.emptyAnswerDB();
      skips = Question.emptySkipDB();
      friends = Friend.emptyDB();
      userSettings : TeamUserSettingsDB = Map.new();
    };
    let null = Map.put(teams, thash, key, team) else Debug.trap("Team must not exist");
    return #ok(info);
  };

  public func update(teams : TeamDB, key : Text, invite : Text, info : TeamInfo, admin : Principal) : Result<TeamInfo> {
    let ?old = Map.get(teams, thash, key) else return #err(#teamNotFound);
    let admins = old.admins;
    Set.add(admins, phash, admin);

    let team : Team = {
      info;
      invite;
      userInvites = old.userInvites;
      members = old.members;
      admins;
      questions = old.questions;
      answers = old.answers;
      skips = old.skips;
      friends = old.friends;
      userSettings = old.userSettings;
    };
    let ?_t = Map.put(teams, thash, key, team) else Debug.trap("Team must exist");
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
        let userInvite = Map.get(x.userInvites, phash, user);
        return {
          key;
          info = x.info;
          invite = if isAdmin ?x.invite else null;
          userInvite;
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
        return key != "" and (
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

  public func listCommon(teams : TeamDB, user1 : Principal, user2 : Principal) : [TeamUserInfo] {
    let all = Map.entries(teams);
    let visible = Iter.filter<(Text, Team)>(
      all,
      func((key, team)) {
        return key != "" and Set.has(team.members, phash, user1) and Set.has(team.members, phash, user2);
      },
    );
    let mapped = Iter.map<(Text, Team), TeamUserInfo>(
      visible,
      func((key, x)) {
        let isAdmin = Set.has(x.admins, phash, user1);
        let isMember = Set.has(x.members, phash, user1);
        let userInvite = Map.get(x.userInvites, phash, user1);
        return {
          key;
          info = x.info;
          invite = if isAdmin ?x.invite else null;
          userInvite;
          permissions = {
            isMember;
            isAdmin;
          };
        };
      },
    );
    Iter.toArray(mapped);
  };

  func generateUserInvite(user : Principal, teamname : Text) : Text {
    let insecureRandom = Prng.SFC32a(); // insecure random numbers
    let seed1 : Nat32 = Text.hash(teamname);
    let seed : Nat32 = Principal.hash(user);
    insecureRandom.init(seed1 ^ seed);
    let invite = Nat32.toText(insecureRandom.next());
    return invite;
  };

  public func get(teams : TeamDB, key : Text, user : Principal, checkMembership : Bool) : Result<Team> {
    let ?team = Map.get(teams, thash, key) else return #err(#teamNotFound);
    if (team.info.listed or not checkMembership or Set.has(team.members, phash, user)) {
      return #ok(team);
    };
    return #err(#notInTeam);
  };

  public func addMember(teams : TeamDB, key : Text, invite : Text, caller : Principal, invitedBy : ?Principal) : Result<TeamInfo> {
    let ?team = Map.get(teams, thash, key) else return #err(#teamNotFound);

    switch (invitedBy) {
      case (?inviter) {
        let ?userInvite = Map.get(team.userInvites, phash, inviter) else return #err(#invalidInvite);
        if (userInvite != invite) { return #err(#invalidInvite) };
      };
      case (null) {
        if (team.invite != invite) { return #err(#invalidInvite) };
      };
    };

    let false = Set.put(team.members, phash, caller) else return #err(#alreadyRegistered);
    Map.set(team.userInvites, phash, caller, generateUserInvite(caller, team.info.name));

    // try to create friend request
    switch (invitedBy) {
      case (?inviter) {
        ignore Friend.request(team.friends, inviter, caller, true);
      };
      case (null) {};
    };

    #ok(team.info);
  };

  public func removeMember(teams : TeamDB, key : Text, user : Principal) : Result<()> {
    let ?team = Map.get(teams, thash, key) else return #err(#teamNotFound);

    let true = Set.remove(team.members, phash, user) else return #err(#notInTeam);

    // delete answers of the user
    Map.delete(team.answers, phash, user);
    Map.delete(team.skips, phash, user);
    Map.delete(team.userInvites, phash, user);

    // delete friends
    let userFriends = Friend.get(team.friends, user);
    for ((friend, status) in userFriends) {
      Friend.delete(team.friends, friend, user); // remove user from friend's connections
    };
    Map.delete(team.friends, phash, user);

    #ok;
  };

  public func deleteAnswers(teams : TeamDB, key : Text, user : Principal) : Result<()> {
    let ?team = Map.get(teams, thash, key) else return #err(#teamNotFound);

    // delete answers of the user
    Map.delete(team.answers, phash, user);
    Map.delete(team.skips, phash, user);

    #ok;
  };

  public func setAdmin(teams : TeamDB, key : Text, user : Principal, admin : Bool) : Result<TeamInfo> {
    let ?team = Map.get(teams, thash, key) else return #err(#teamNotFound);

    if (admin) {
      let false = Set.put(team.admins, phash, user) else return #err(#alreadyRegistered);
    } else {
      let true = Set.remove(team.admins, phash, user) else return #err(#userNotFound);
    };

    #ok(team.info);
  };

  public func isAdmin(team : Team, user : Principal) : Bool = Set.has(team.admins, phash, user);
  public func isMember(team : Team, user : Principal) : Bool = Set.has(team.members, phash, user);
  public func getMembers(team : Team) : [Principal] = Set.toArray(team.members);
  public func getAdmins(team : Team) : [Principal] = Set.toArray(team.admins);

  public func isTeamAdmin(teams : TeamDB, key : Text, user : Principal) : Bool {
    let ?team = Map.get(teams, thash, key) else return false;
    Set.has(team.admins, phash, user);
  };
};
