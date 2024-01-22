import Principal "mo:base/Principal";
import Hash "mo:base/Hash";
import List "mo:base/List";
import HashMap "mo:base/HashMap";
import Int "mo:base/Int";
import Text "mo:base/Text";
import Result "mo:base/Result";
import Time "mo:base/Time";
import Option "mo:base/Option";
import Buffer "mo:base/Buffer";
import Nat32 "mo:base/Nat32";
import Nat8 "mo:base/Nat8";
import Nat "mo:base/Nat";
import Int8 "mo:base/Int8";
import Int32 "mo:base/Int32";
import Array "mo:base/Array";
import Float "mo:base/Float";
import Order "mo:base/Order";
import None "mo:base/None";
import Cycles "mo:base/ExperimentalCycles";
import Blob "mo:base/Blob";
import Debug "mo:base/Debug";

import IterTools "mo:itertools/Iter";

import Question "Question";
import User "User";
import Friend "Friend";
import Team "Team";
import Admin "Admin";
import Matching "Matching";
import Configuration "Configuration";
import Error "Error";
import Iter "mo:base/Iter";
import Prng "mo:prng";
import Nat64 "mo:base/Nat64";
import TextHelper "helper/TextHelper";
import Nat8Extra "helper/Nat8Extra";

import TypesV1 "deprecated/TypesV1";

actor {

  //TYPES INDEX
  type User = User.User;
  type Question = Question.Question;
  type StableQuestion = Question.StableQuestion;
  type QuestionID = Question.QuestionID;
  type Answer = Question.Answer;
  type Skip = Question.Skip;
  type QuestionStats = Question.QuestionStats;
  type FriendStatus = Friend.FriendStatus;
  type Error = Error.Error;
  type Team = Team.Team;
  type TeamInfo = Team.TeamInfo;
  type TeamUserInfo = Team.TeamUserInfo;
  type TeamStats = Team.TeamStats;

  type MatchingFilter = Matching.MatchingFilter;
  type UserMatch = Matching.UserMatch;
  type AdminPermissions = Admin.Permissions;

  type Result<T> = Result.Result<T, Error>;
  type UserPermissions = { user : User; permissions : AdminPermissions };

  // Aliases to get deterministic names for use in frontend code
  type ResultVoid = Result<()>;
  type ResultUser = Result<UserPermissions>;
  type ResultUsers = Result<[User]>;
  type ResultUserPermissions = Result<[UserPermissions]>;
  type ResultQuestion = Result<Question>;
  type ResultAnswer = Result<Answer>;
  type ResultSkip = Result<Skip>;
  type ResultUserMatch = Result<UserMatch>;
  type ResultUserMatches = Result<[UserMatch]>;
  type Friend = (UserMatch, FriendStatus);
  type ResultFriends = Result<[Friend]>;
  type ResultTeam = Result<TeamInfo>;
  type ResultTeams = Result<[TeamUserInfo]>;
  type ResultTeamStats = Result<TeamStats>;
  type ResultQuestionStats = Result<[QuestionStats]>;

  // UTILITY FUNCTIONS

  // DATA STORAGE
  type UserDB = User.UserDB;
  type QuestionDB = Question.QuestionDB;
  type AnswerDB = Question.AnswerDB;
  type SkipDB = Question.SkipDB;
  type FriendDB = Friend.FriendDB;
  type TeamDB = Team.TeamDB;
  type AdminDB = Admin.AdminDB;

  type DBv1 = {
    users : UserDB;
    teams : TeamDB;
  };

  // Stable vars
  stable var db_v1 : DBv1 = {
    users = User.emptyDB();
    teams = Team.emptyDB();
  };

  stable var admins_v1 : TypesV1.AdminDB = TypesV1.emptyDB();
  stable var admins_v2 : AdminDB = Admin.emptyDB();

  // alias for current db version
  var db = db_v1;
  var admins = admins_v2;

  // Upgrade canister
  system func preupgrade() {
    // make sure all data is stored in stable memory
  };

  system func postupgrade() {
    // transfer data from old db version
    //migrate_DBv1_v2()
    // Cleanup old stable data
    //db_v1 := {
    //  users = User.emptyDB();
    //  teams = Team.emptyDB();
    //};
    admins_v1 := TypesV1.emptyDB();
  };

  var insecureRandom = Prng.SFC64a(); // insecure random numbers

  // PUBLIC API

  // Get own principal
  public query ({ caller }) func whoami() : async Principal {
    caller;
  };

  public query ({ caller }) func getPermissions() : async {
    user : ?User;
    principal : Principal;
    permissions : AdminPermissions;
  } {
    {
      user = User.get(db.users, caller);
      principal = caller;
      permissions = Admin.getPermissions(admins, caller);
    };
  };

  public shared ({ caller }) func setPermissions(user : Text, permissions : AdminPermissions) : async ResultVoid {
    if (not Principal.isController(caller)) {
      assertPermission(caller, #all);
    };
    let ?p = User.getPrincipal(db.users, user) else return #err(#userNotFound);
    Admin.setPermissions(admins, p, permissions);
    #ok;
  };

  public shared query ({ caller }) func listAdmins() : async ResultUserPermissions {
    assertPermission(caller, #createBackup);

    func toUserPermissions((principal : Principal, permissions : AdminPermissions)) : ?UserPermissions {
      let ?user = User.get(db.users, principal) else return null;
      return ?{ permissions; user };
    };

    let all = IterTools.mapFilter<(Principal, AdminPermissions), UserPermissions>(
      Admin.list(admins),
      toUserPermissions,
    );

    #ok(Iter.toArray<UserPermissions>(all));
  };

  public shared query ({ caller }) func listUsers() : async ResultUsers {
    assertPermission(caller, #createBackup);

    let all = Iter.map<(Principal, User), User>(
      User.list(db.users),
      func((p, u)) = u,
    );

    #ok(Iter.toArray<User>(all));
  };

  // Create default new team
  public shared ({ caller }) func createTeam(teamKey : Text, invite : Text, info : TeamInfo) : async ResultTeam {
    if (not Admin.hasPermission(admins, caller, #createTeam)) return #err(#permissionDenied);
    Team.create(db.teams, teamKey, invite, info, caller);
  };

  public shared ({ caller }) func updateTeam(teamKey : Text, invite : Text, info : TeamInfo) : async ResultTeam {
    if (not Team.isTeamAdmin(db.teams, teamKey, caller)) return #err(#permissionDenied);
    Team.update(db.teams, teamKey, invite, info, caller);
  };

  public shared ({ caller }) func joinTeam(teamKey : Text, invite : Text) : async ResultTeam {
    Team.addMember(db.teams, teamKey, invite, caller);
  };

  public shared ({ caller }) func leaveTeam(teamKey : Text, user : Text) : async ResultVoid {
    let ?p = User.getPrincipal(db.users, user) else return #err(#userNotFound);
    let isAllowed = p == caller or Team.isTeamAdmin(db.teams, teamKey, caller);
    if (not isAllowed) { return #err(#permissionDenied) };

    Team.removeMember(db.teams, teamKey, p);
  };

  // Get teams
  public shared query ({ caller }) func listTeams(known : [Text]) : async ResultTeams {
    let showAll = Admin.getPermissions(admins, caller).listAllTeams;
    Team.list(db.teams, caller, known, showAll);
  };

  public shared query ({ caller }) func getTeamStats(teamKey : Text) : async ResultTeamStats {
    Team.getStats(db.teams, teamKey);
  };

  public shared query ({ caller }) func getTeamMembers(teamKey : Text) : async ResultUsers {
    let team = switch (Team.get(db.teams, teamKey, caller)) {
      case (#ok(t)) t;
      case (#err(e)) return #err(e);
    };
    let true = Team.isMember(team, caller) else return #err(#notInTeam);

    let members = Team.getMembers(team);
    let users = Array.map<Principal, User>(
      members,
      func(p) {
        let u = switch (User.get(db.users, p)) {
          case (?value) { value };
          case (null) { User.create(Principal.toText(p), "N/A") };
        };
        u;
      },
    );

    return #ok(users);
  };

  // Create default new user with only a username
  public shared ({ caller }) func createUser(displayName : Text, contact : Text) : async ResultUser {
    let u = User.add(db.users, displayName, contact, caller);
    userWithPermissions(u, caller);
  };

  func userWithPermissions(result : Result<User>, principal : Principal) : ResultUser {
    Result.mapOk<User, UserPermissions, Error>(
      result,
      func(user) {
        {
          user;
          permissions = Admin.getPermissions(admins, principal);
        };
      },
    );

  };

  public shared query ({ caller }) func getUser() : async ResultUser {
    let ?user = User.get(db.users, caller) else return #err(#notRegistered);
    userWithPermissions(#ok(user), caller);
  };

  public shared ({ caller }) func updateProfile(user : User) : async ResultUser {
    let u = User.update(db.users, user, caller);
    userWithPermissions(u, caller);
  };

  public shared ({ caller }) func createQuestion(teamKey : Text, question : Text, color : Text) : async ResultQuestion {
    switch (User.checkFunds(db.users, #createQuestion, caller)) {
      case (#ok(_)) { /* user has sufficient funds */ };
      case (#err(e)) return #err(e);
    };

    let team = switch (Team.get(db.teams, teamKey, caller)) {
      case (#ok(t)) t;
      case (#err(e)) return #err(e);
    };

    let result = Question.add(team.questions, question, color, caller);
    let #ok(q) = result else return result;

    let #ok(_) = User.reward(db.users, #createQuestion, caller) else Debug.trap("Bug: Reward failed. checkFunds should have returned an error already");

    ignore User.increment(db.users, #asked, caller);
    #ok(q);
  };

  public shared ({ caller }) func deleteQuestion(teamKey : Text, question : Question) : async ResultVoid {
    let team = switch (Team.get(db.teams, teamKey, caller)) {
      case (#ok(t)) t;
      case (#err(e)) return #err(e);
    };

    let true = Team.isAdmin(team, caller) else return #err(#notInTeam);

    let q = Question.getQuestion(team.questions, question.id);

    // verify that it is the same question
    if (q.created != question.created) return #err(#questionNotFound);

    Question.hide(team.questions, question.id, true);

    #ok;
  };

  public shared query ({ caller }) func getUnansweredQuestions(teamKey : Text, limit : Nat) : async [Question] {
    let team = switch (Team.get(db.teams, teamKey, caller)) {
      case (#ok(t)) t;
      case (#err(e)) return [];
    };

    let iter = Question.unanswered(team.questions, team.answers, team.skips, caller);
    let limited = IterTools.take(iter, Nat.min(limit, Configuration.api.maxPageSize));
    Iter.toArray(limited);
  };

  // TODO? remove Answer from return type?
  public shared query ({ caller }) func getAnsweredQuestions(teamKey : Text, limit : Nat) : async [(Question, Answer)] {
    let team = switch (Team.get(db.teams, teamKey, caller)) {
      case (#ok(t)) t;
      case (#err(e)) return [];
    };

    let iter = Question.answered(team.questions, team.answers, caller);
    let limited = IterTools.take(iter, Nat.min(limit, Configuration.api.maxPageSize));
    Iter.toArray(limited);
  };

  public shared query ({ caller }) func getQuestionStats(teamKey : Text, limit : Nat) : async ResultQuestionStats {
    let team = switch (Team.get(db.teams, teamKey, caller)) {
      case (#ok(t)) t;
      case (#err(e)) return #err(e);
    };

    let iter = Question.getQuestionStats(team.questions, team.answers, team.skips);
    let limited = IterTools.take(iter, Nat.min(limit, Configuration.api.maxPageSize));

    #ok(Iter.toArray(limited));
  };

  public shared query ({ caller }) func getOwnQuestions(teamKey : Text, limit : Nat) : async [Question] {
    let team = switch (Team.get(db.teams, teamKey, caller)) {
      case (#ok(t)) t;
      case (#err(e)) return [];
    };

    let iter = Question.getByCreator(team.questions, caller);
    let limited = IterTools.take(iter, Nat.min(limit, Configuration.api.maxPageSize));
    Iter.toArray(limited);
  };

  // Add an answer
  public shared ({ caller }) func submitAnswer(teamKey : Text, question : QuestionID, answer : Bool, weight : Nat) : async ResultAnswer {
    let boost = Nat.max(1, Nat.min(weight, Configuration.question.maxBoost));

    switch (User.checkFunds(db.users, #createAnswer(boost), caller)) {
      case (#ok(_)) { /* user has sufficient funds */ };
      case (#err(e)) return #err(e);
    };

    let team = switch (Team.get(db.teams, teamKey, caller)) {
      case (#ok(t)) t;
      case (#err(e)) return #err(e);
    };

    let a : Answer = {
      question;
      answer;
      weight = boost;
      created = Time.now();
    };
    let prev = Question.putAnswer(team.answers, a, caller);

    switch (prev) {
      case (?previous) {
        if (a.weight > previous.weight) {
          // TODO: charge for boost?
        };
      };
      case (null) {
        let #ok(_) = User.reward(db.users, #createAnswer(boost), caller) else Debug.trap("Bug: Reward failed. checkFunds should have returned an error already");

        ignore User.increment(db.users, #answered, caller);
        if (boost > 1) {
          let q = Question.get(team.questions, question);
          ignore User.increment(db.users, #boost, q.creator);
        };
        let points = Configuration.question.answerReward + (boost : Int - 1) * Configuration.question.boostReward;
        Question.changePoints(team.questions, question, points);
      };
    };

    #ok(a);
  };

  // Add a skip
  public shared ({ caller }) func submitSkip(teamKey : Text, question : Nat) : async ResultSkip {
    let team = switch (Team.get(db.teams, teamKey, caller)) {
      case (#ok(t)) t;
      case (#err(e)) return #err(e);
    };

    let s : Skip = { question; reason = #skip };
    let prev = Question.putSkip(team.skips, s, caller);
    Question.changePoints(team.questions, question, Configuration.question.skipReward);
    #ok(s);
  };

  public shared query ({ caller }) func getMatches(teamKey : Text) : async ResultUserMatches {
    let team = switch (Team.get(db.teams, teamKey, caller)) {
      case (#ok(t)) t;
      case (#err(e)) return #err(e);
    };

    if (Question.countUserAnswers(team.answers, caller) < Configuration.matching.minAnswers) {
      return #err(#notEnoughAnswers);
    };

    let userFiltered = User.find(db.users, team.members);

    // remove caller and friends
    let withoutSelf = Iter.filter<(Principal, User)>(userFiltered, func(p, u) = p != caller);
    let withoutFriends = Iter.filter<(Principal, User)>(withoutSelf, func(p, u) = not Friend.has(team.friends, caller, p));

    let withScore = IterTools.mapFilter<(Principal, User), UserMatch>(
      withoutFriends,
      func(id, user) {
        let res = Matching.getUserMatch(db.users, team.questions, team.answers, team.skips, caller, id, false);
        Result.toOption(res); // TODO?: handle errors instead of removing them?
      },
    );

    let all = Iter.toArrayMut<UserMatch>(withScore);

    Array.sortInPlace<UserMatch>(all, func(a, b) = Nat8Extra.compareDesc(a.cohesion, b.cohesion));

    #ok(Array.freeze(all));
  };

  // returns both approved and unapproved friends
  public shared query ({ caller }) func getFriends(teamKey : Text) : async ResultFriends {
    let team = switch (Team.get(db.teams, teamKey, caller)) {
      case (#ok(t)) t;
      case (#err(e)) return #err(e);
    };

    let userFriends = Friend.get(team.friends, caller);

    let friends = Iter.toArray(Friend.get(team.friends, caller));

    func toUserMatch((p : Principal, status : FriendStatus)) : ?(UserMatch, FriendStatus) {
      let showNonPublic = (status == #connected or status == #requestReceived);
      let #ok(userMatch) = Matching.getUserMatch(db.users, team.questions, team.answers, team.skips, caller, p, showNonPublic) else return null;
      // TODO?: handle errors instead of removing them?
      ?(userMatch, status);
    };

    let filtered = IterTools.mapFilter<(Principal, FriendStatus), (UserMatch, FriendStatus)>(
      userFriends,
      toUserMatch,
    );

    #ok(Iter.toArray(filtered));
  };

  /// Send a friend request to a user
  public shared ({ caller }) func sendFriendRequest(teamKey : Text, username : Text) : async ResultVoid {
    let team = switch (Team.get(db.teams, teamKey, caller)) {
      case (#ok(t)) t;
      case (#err(e)) return #err(e);
    };

    let ?id = User.getPrincipal(db.users, username) else return #err(#userNotFound);
    Friend.request(team.friends, caller, id, true);
  };

  public shared ({ caller }) func answerFriendRequest(teamKey : Text, username : Text, accept : Bool) : async ResultVoid {
    let team = switch (Team.get(db.teams, teamKey, caller)) {
      case (#ok(t)) t;
      case (#err(e)) return #err(e);
    };

    let ?id = User.getPrincipal(db.users, username) else return #err(#userNotFound);
    if (accept) {
      Friend.request(team.friends, caller, id, true);
    } else {
      Friend.request(team.friends, caller, id, false);
    };
  };

  func assertPermission(caller : Principal, permission : Admin.Permission) {
    if (not Admin.hasPermission(admins, caller, permission)) {
      Debug.trap("Access denied!");
    };
  };

  // Trap if caller is not a controller of the canister
  func assertAdmin(caller : Principal) {
    if (not Principal.isController(caller)) {
      Debug.trap("Access denied!");
    };
  };

  /// Create a backup of users
  public query ({ caller }) func backupUsers(offset : Nat, limit : Nat) : async [(Principal, User)] {
    assertAdmin(caller);

    let all = User.backup(db.users);
    let withOffset = IterTools.skip(all, offset);
    let withLimit = IterTools.take(withOffset, limit);
    Iter.toArray(withLimit);
  };

  /// Create a backup of friend status
  public query ({ caller }) func backupConnections(teamKey : Text, offset : Nat, limit : Nat) : async [(Principal, Principal, FriendStatus)] {
    assertAdmin(caller);

    let team = switch (Team.get(db.teams, teamKey, caller)) {
      case (#ok(t)) t;
      case (#err(e)) return Debug.trap("couldn't get team");
    };

    let all = Friend.backup(team.friends);
    let withOffset = IterTools.skip(all, offset);
    let withLimit = IterTools.take(withOffset, limit);
    Iter.toArray(withLimit);
  };

  /// Create a backup of questions
  public query ({ caller }) func backupQuestions(teamKey : Text, offset : Nat, limit : Nat) : async [StableQuestion] {
    assertAdmin(caller);

    let team = switch (Team.get(db.teams, teamKey, caller)) {
      case (#ok(t)) t;
      case (#err(e)) return Debug.trap("couldn't get team");
    };

    let all = Question.backup(team.questions);
    let withOffset = IterTools.skip(all, offset);
    let withLimit = IterTools.take(withOffset, limit);
    Iter.toArray(withLimit);
  };

  /// Create a backup of answers
  public query ({ caller }) func backupAnswers(teamKey : Text, offset : Nat, limit : Nat) : async [StableQuestion] {
    assertAdmin(caller);

    let team = switch (Team.get(db.teams, teamKey, caller)) {
      case (#ok(t)) t;
      case (#err(e)) return Debug.trap("couldn't get team");
    };

    let all = Question.backup(team.questions);
    let withOffset = IterTools.skip(all, offset);
    let withLimit = IterTools.take(withOffset, limit);
    Iter.toArray(withLimit);
  };

  public shared ({ caller }) func airdrop(user : Text, tokens : Int) : async ResultVoid {
    assertAdmin(caller);

    let ?p = User.getPrincipal(db.users, user) else return #err(#userNotFound);

    switch (User.reward(db.users, #custom(tokens), p)) {
      case (#ok(_)) #ok;
      case (#err(e)) #err(e);
    };
  };

  public shared ({ caller }) func selfDestruct(confirm : Text) {
    assertAdmin(caller);

    if (confirm != "DELETE EVERYTHING!") Debug.trap("canceled");

    db_v1 := {
      users = User.emptyDB();
      teams = Team.emptyDB();
    };
    db := db_v1;
  };

  public shared ({ caller }) func createTestData(teamKey : Text, questions : Nat, users : Nat) : async Nat {
    assertAdmin(caller);

    let team = switch (Team.get(db.teams, teamKey, caller)) {
      case (#ok(t)) t;
      case (#err(e)) return Debug.trap("couldn't get team");
    };

    let res = User.add(db.users, "admin", "admin@allkinds", caller);

    for (i in Iter.range(1, questions)) {
      let text = "Question " # Nat.toText(i) # "?";

      let res = Question.add(team.questions, text, ["red", "green", "orange", "black", "purple"][i % 5], caller);
      switch (res) {
        case (#ok(_)) {};
        case (#err(error)) {
          Debug.trap(debug_show (error) # " when creating question " # text);
        };
      };
    };

    let rand = [0, 1, 0, 1, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 1, 1, 1, 0, 0, 1, 1, 1, 0, 1, 1, 0, 1, 1, 1, 1, 0, 1, 1, 1, 1, 0, 0, 1, 1, 1, 1, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 1, 0, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 0, 0, 1, 0, 0, 0, 1, 1, 0, 0, 0, 0, 1, 1, 0, 0, 1, 0, 0, 0, 1, 1, 1, 0, 0, 0, 1, 0, 0, 0, 1, 1, 0, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0, 1, 1, 0, 0, 1, 0, 0, 1, 1, 0, 1, 1, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 1, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 0, 0, 1, 0, 0, 0, 1, 1, 0, 1, 1, 1, 1, 1, 0, 0, 0, 1, 1, 1, 0, 1, 0, 0, 1, 0, 1, 1, 1, 1, 0, 0, 1, 1, 1, 1, 1, 1, 0, 0, 0, 1, 1, 0, 1, 1, 0, 1, 0, 0, 1, 1, 1, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 0, 1, 1, 0, 0, 1, 1, 0, 1, 1, 1, 1, 1, 0, 1, 1, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 0, 0, 1, 1, 1, 1];
    var randI = 1;
    for (i in Iter.range(1, users)) {
      let name = "User." # Nat.toText(i);

      let principal = Principal.fromBlob(Blob.fromArray([Nat8.fromNat(i % 256), Nat8.fromNat((i / 256) % 256), 0x03]));
      let res = User.add(db.users, name, name # "@allkinds", principal);
      switch (res) {
        case (#ok(_)) {};
        case (#err(error)) {
          Debug.trap(debug_show (error) # " when creating user " # name);
        };
      };

      let res2 = Team.addMember(db.teams, teamKey, team.invite, principal);
      switch (res2) {
        case (#ok(_)) {};
        case (#err(error)) {
          Debug.trap(debug_show (error) # " when adding user " # name # " as a member");
        };
      };

      let qs = Question.unanswered(team.questions, team.answers, team.skips, principal);
      for (q in qs) {
        randI += 1;
        let a : Answer = {
          question = q.id;
          answer = rand[randI % 256] == 0;
          weight = 1;
          created = Time.now();
        };
        ignore Question.putAnswer(team.answers, a, principal);
      };
    };

    return randI;
  };

};
