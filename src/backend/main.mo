import Array "mo:base/Array";
import Blob "mo:base/Blob";
import Buffer "mo:base/Buffer";
import Debug "mo:base/Debug";
import Cycles "mo:base/ExperimentalCycles";
import Float "mo:base/Float";
import Hash "mo:base/Hash";
import HashMap "mo:base/HashMap";
import Int "mo:base/Int";
import Int32 "mo:base/Int32";
import Int8 "mo:base/Int8";
import Iter "mo:base/Iter";
import List "mo:base/List";
import Nat "mo:base/Nat";
import Nat32 "mo:base/Nat32";
import Nat64 "mo:base/Nat64";
import Nat8 "mo:base/Nat8";
import None "mo:base/None";
import Option "mo:base/Option";
import Order "mo:base/Order";
import Principal "mo:base/Principal";
import Result "mo:base/Result";
import Text "mo:base/Text";
import Time "mo:base/Time";
import IterTools "mo:itertools/Iter";
import Map "mo:map/Map";
import Set "mo:map/Set";
import Prng "mo:prng";

import Admin "Admin";
import Chat "Chat";
import Configuration "Configuration";
import Error "Error";
import Friend "Friend";
import Nat8Extra "helper/Nat8Extra";
import TextHelper "helper/TextHelper";
import Matching "Matching";
import Notification "Notification";
import Performance "Performance";
import Question "Question";
import Team "Team";
import TypesV1 "types/TypesV1";
import TypesV2 "types/TypesV2";
import TypesV3 "types/TypesV3";
import TypesV4 "types/TypesV4";
import TypesV5 "types/Types";
import Types "types/Types";
import User "User";

actor {

  //TYPES INDEX
  type User = Types.User;
  type Question = Types.Question;
  type StableQuestion = Types.StableQuestion;
  type QuestionID = Types.QuestionID;
  type Answer = Types.Answer;
  type Skip = Types.Skip;
  type QuestionStats = Types.QuestionStats;
  type FriendStatus = Types.FriendStatus;
  type Error = Error.Error;
  type Team = Types.Team;
  type TeamInfo = Types.TeamInfo;
  type TeamUserInfo = Types.TeamUserInfo;
  type TeamStats = Types.TeamStats;
  type Notification = Types.Notification;

  type UserMatch = Matching.UserMatch;
  type AdminPermission = Types.AdminPermission;
  type AdminPermissions = Types.AdminPermissions;

  type Result<T> = Result.Result<T, Error>;
  type UserPermissions = Types.UserPermissions;

  type UserNotifications = Types.UserNotifications;
  type Message = Types.Message;
  type ChatStatus = Types.ChatStatus;

  let { thash; phash } = Set;

  // Aliases to get deterministic names for use in frontend code
  type ResultVoid = Result<()>;
  type ResultNat = Result<Nat>;
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
  type ResultUsersNotifications = Result<[UserNotifications]>;
  type ResultMessages = Result<{ messages : [Message]; status : ChatStatus }>;

  // UTILITY FUNCTIONS

  // DATA STORAGE
  type UserDB = Types.UserDB;
  type QuestionDB = Types.QuestionDB;
  type AnswerDB = Types.AnswerDB;
  type SkipDB = Types.SkipDB;
  type FriendDB = Types.FriendDB;
  type TeamDB = Types.TeamDB;
  type AdminDB = Types.AdminDB;
  type MessageDB = Types.MessageDB;

  // Stable vars
  stable var db_v1 : TypesV2.DB = TypesV2.emptyDB();
  // db_v2 is the same as v1
  stable var db_v3 : TypesV3.DB = TypesV3.emptyDB();
  stable var db_v4 : TypesV4.DB = TypesV4.emptyDB();
  stable var db_v5 : TypesV5.DB = TypesV5.emptyDB();

  stable var admins_v1 : TypesV1.AdminDB = TypesV1.emptyAdminDB();
  stable var admins_v2 : AdminDB = TypesV2.emptyAdminDB();

  stable var messageDB_v1 : MessageDB = TypesV4.emptyMessageDB();

  // alias for current db version
  var db : Types.DB = db_v5;
  var admins = admins_v2;
  var messageDB = messageDB_v1;
  let performance = Performance.emptyDB();

  // Upgrade canister
  system func preupgrade() {
    //     !!!!!!!!!!!!!!!!!!!!!!!
    //     !!! DO NOT USE THIS !!!
    //     !!!!!!!!!!!!!!!!!!!!!!!
    // ANY ERROR HERE CAN LOCK THE CANISTER
    // AND PREVENT FURTHER UPGRADES WITHOUT
    // REINSTALL AND ALL DATA WILL BE LOST!
  };

  system func postupgrade() {
    if (false) {
      db_v5 := TypesV5.migrateV4(db_v4);
      //keeping old db_v3 around for now as a backup in case anything goes wrong with the migration
      //Debug.print(debug_show(db_v4.users.byUsername));
      Debug.print("upgraded to v5");
    };
  };

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
      return ?{ permissions; user; notifications = [] };
    };

    let all = IterTools.mapFilter<(Principal, AdminPermissions), UserPermissions>(
      Admin.list(admins),
      toUserPermissions,
    );

    #ok(Iter.toArray<UserPermissions>(all));
  };

  public shared query ({ caller }) func listUsers() : async ResultUsersNotifications {
    assertPermission(caller, #createBackup);

    func toUserNotifications((p : Principal, u : User)) : UserNotifications {
      return {
        user = u;
        notifications = Notification.getAll(db.users, db.teams, messageDB, p, false);
      };
    };

    let all = Iter.map<(Principal, User), UserNotifications>(User.list(db.users), toUserNotifications);

    #ok(Iter.toArray<UserNotifications>(all));
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

  public shared ({ caller }) func joinTeam(teamKey : Text, invite : Text, invitedBy : ?Text) : async ResultTeam {
    if (Principal.isAnonymous(caller)) return #err(#notLoggedIn);
    let inviter : ?Principal = switch (invitedBy) {
      case (?user) {
        let ?u = User.getPrincipal(db.users, user) else return #err(#userNotFound);
        ?u;
      };
      case (null) null;
    };
    Team.addMember(db.teams, teamKey, invite, caller, inviter);
  };

  public shared ({ caller }) func setTeamAdmin(teamKey : Text, user : Text, admin : Bool) : async ResultTeam {
    if (not Team.isTeamAdmin(db.teams, teamKey, caller)) return #err(#permissionDenied);
    let ?p = User.getPrincipal(db.users, user) else return #err(#userNotFound);

    Team.setAdmin(db.teams, teamKey, p, admin);
  };

  public shared ({ caller }) func leaveTeam(teamKey : Text, user : Text) : async ResultVoid {
    let ?p = User.getPrincipal(db.users, user) else return #err(#userNotFound);
    let isAllowed = p == caller or Team.isTeamAdmin(db.teams, teamKey, caller);
    if (not isAllowed) { return #err(#permissionDenied) };

    Team.removeMember(db.teams, teamKey, p);
  };

  public shared ({ caller }) func deleteUser(user : Text) : async ResultVoid {
    let ?p = User.getPrincipal(db.users, user) else return #err(#userNotFound);
    if (caller != p) return #err(#permissionDenied);
    assert (caller == p);

    // remove user from all teams
    let teams = switch (Team.list(db.teams, p, [], false)) {
      case (#ok(v)) { v };
      case (#err(e)) { return #err(e) };
    };
    for (team in teams.vals()) {
      ignore Team.removeMember(db.teams, team.key, p);
      ignore Team.setAdmin(db.teams, team.key, p, false);
    };

    // TODO?: unassign questions

    // unregister user
    return User.delete(db.users, p, user);
  };

  public shared ({ caller }) func deleteAnswers(teamKey : Text, user : Text) : async ResultVoid {
    let ?p = User.getPrincipal(db.users, user) else return #err(#userNotFound);
    if (caller != p) return #err(#permissionDenied);
    assert (caller == p);

    ignore Team.deleteAnswers(db.teams, teamKey, p);

    return #ok;
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
    let team = switch (Team.get(db.teams, teamKey, caller, true)) {
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
          case (null) { User.create(Principal.toText(p), "N/A", "") };
        };
        u;
      },
    );

    return #ok(users);
  };

  public shared query ({ caller }) func getTeamAdmins(teamKey : Text) : async ResultUsers {
    let team = switch (Team.get(db.teams, teamKey, caller, false)) {
      case (#ok(t)) t;
      case (#err(e)) return #err(e);
    };
    let true = Team.isAdmin(team, caller) else return #err(#notInTeam);

    let admins = Team.getAdmins(team);
    let users = Array.map<Principal, User>(
      admins,
      func(p) {
        let u = switch (User.get(db.users, p)) {
          case (?value) { value };
          case (null) { User.create(Principal.toText(p), "N/A", "") };
        };
        u;
      },
    );

    return #ok(users);
  };

  // Create default new user with only a username
  public shared ({ caller }) func createUser(displayName : Text, about : Text, contact : Text) : async ResultUser {
    let u = User.add(db.users, displayName, about, contact, caller);
    userWithPermissions(u, caller);
  };

  func userWithPermissions(result : Result<User>, principal : Principal) : ResultUser {
    Result.mapOk<User, UserPermissions, Error>(
      result,
      func(user) {
        {
          user;
          permissions = Admin.getPermissions(admins, principal);
          notifications = Notification.getAll(db.users, db.teams, messageDB, principal, true);
        };
      },
    );

  };

  public shared query ({ caller }) func getUser() : async ResultUser {
    let ?user = User.get(db.users, caller) else return #err(#notRegistered(caller));
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

    let team = switch (Team.get(db.teams, teamKey, caller, true)) {
      case (#ok(t)) t;
      case (#err(e)) return #err(e);
    };

    let result = Question.add(team.questions, question, color, caller);
    let #ok(q) = result else return result;

    let #ok(_) = User.reward(db.users, #createQuestion, caller) else Debug.trap("Bug: Reward failed. checkFunds should have returned an error already");

    ignore User.increment(db.users, #asked, caller);
    #ok(q);
  };

  public shared ({ caller }) func deleteQuestion(teamKey : Text, question : Question, hide : Bool) : async ResultVoid {
    let team = switch (Team.get(db.teams, teamKey, caller, true)) {
      case (#ok(t)) t;
      case (#err(e)) return #err(e);
    };

    let true = Team.isAdmin(team, caller) else return #err(#notInTeam);

    let q = Question.getQuestion(team.questions, question.id);

    // verify that it is the same question
    if (q.created != question.created) return #err(#questionNotFound);

    Question.hide(team.questions, question.id, hide);

    #ok;
  };

  public shared query ({ caller }) func getUnansweredQuestions(teamKey : Text, limit : Nat) : async [Question] {
    let team = switch (Team.get(db.teams, teamKey, caller, true)) {
      case (#ok(t)) t;
      case (#err(e)) return [];
    };

    let iter = Question.unanswered(team.questions, team.answers, team.skips, caller);
    let limited = IterTools.take(iter, Nat.min(limit, Configuration.api.maxPageSize));
    Iter.toArray(limited);
  };

  // TODO? remove Answer from return type?
  public shared query ({ caller }) func getAnsweredQuestions(teamKey : Text, limit : Nat) : async [(Question, Answer)] {
    let team = switch (Team.get(db.teams, teamKey, caller, true)) {
      case (#ok(t)) t;
      case (#err(e)) return [];
    };

    let iter = Question.answered(team.questions, team.answers, caller);
    let limited = IterTools.take(iter, Nat.min(limit, Configuration.api.maxPageSize));
    Iter.toArray(limited);
  };

  public shared query ({ caller }) func getQuestionStats(teamKey : Text, limit : Nat) : async ResultQuestionStats {
    let team = switch (Team.get(db.teams, teamKey, caller, true)) {
      case (#ok(t)) t;
      case (#err(e)) return #err(e);
    };

    let iter = Question.getQuestionStats(team.questions, team.answers, team.skips, /* showHidden = */ false);
    let limited = IterTools.take(iter, Nat.min(limit, Configuration.api.maxPageSize));

    #ok(Iter.toArray(limited));
  };

  public shared query ({ caller }) func getOwnQuestions(teamKey : Text, limit : Nat) : async [Question] {
    let team = switch (Team.get(db.teams, teamKey, caller, true)) {
      case (#ok(t)) t;
      case (#err(e)) return [];
    };

    let iter = Question.getByCreator(team.questions, caller, /* showHidden = */ true);
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

    let team = switch (Team.get(db.teams, teamKey, caller, true)) {
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
    let team = switch (Team.get(db.teams, teamKey, caller, true)) {
      case (#ok(t)) t;
      case (#err(e)) return #err(e);
    };

    let s : Skip = { question; reason = #skip };
    ignore Question.putSkip(team.skips, s, caller);
    Question.changePoints(team.questions, question, Configuration.question.skipReward);
    #ok(s);
  };

  public shared query ({ caller }) func getMatches(teamKey : Text) : async ResultUserMatches {
    let team = switch (Team.get(db.teams, teamKey, caller, true)) {
      case (#ok(t)) t;
      case (#err(e)) return #err(e);
    };

    if (Question.countUserAnswers(team.answers, caller) < Configuration.matching.minAnswers) {
      return #err(#notEnoughAnswers);
    };

    let userFiltered = User.find(db.users, team.members);
    let hideAll = true;
    let hideUncommon = true;

    // remove caller and friends
    let withoutSelf = Iter.filter<(Principal, User)>(userFiltered, func(p, u) = p != caller);
    let withoutFriends = Iter.filter<(Principal, User)>(withoutSelf, func(p, u) = not Friend.has(team.friends, caller, p));

    let withScore = IterTools.mapFilter<(Principal, User), UserMatch>(
      withoutFriends,
      func(id, user) {
        let res = Matching.getUserMatch(db.users, team.questions, team.answers, team.skips, caller, id, hideAll, hideUncommon);
        Result.toOption(res); // TODO?: handle errors instead of removing them?
      },
    );

    let all = Iter.toArrayMut<UserMatch>(withScore);

    Array.sortInPlace<UserMatch>(all, func(a, b) = Nat8Extra.compareDesc(a.cohesion, b.cohesion));

    #ok(Array.freeze(all));
  };

  // returns both approved and unapproved friends
  public shared query ({ caller }) func getFriends(teamKey : Text) : async ResultFriends {
    let team = switch (Team.get(db.teams, teamKey, caller, true)) {
      case (#ok(t)) t;
      case (#err(e)) return #err(e);
    };

    let userFriends = Friend.get(team.friends, caller);

    func toUserMatch((p : Principal, status : FriendStatus)) : ?(UserMatch, FriendStatus) {
      let hideAll = not (status == #connected or status == #requestReceived);
      let hideUncommon = true;

      let #ok(userMatch) = Matching.getUserMatch(db.users, team.questions, team.answers, team.skips, caller, p, hideAll, hideUncommon) else return null;
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
    let team = switch (Team.get(db.teams, teamKey, caller, true)) {
      case (#ok(t)) t;
      case (#err(e)) return #err(e);
    };

    let ?id = User.getPrincipal(db.users, username) else return #err(#userNotFound);
    Friend.request(team.friends, caller, id, true);
  };

  public shared ({ caller }) func answerFriendRequest(teamKey : Text, username : Text, accept : Bool) : async ResultVoid {
    let team = switch (Team.get(db.teams, teamKey, caller, true)) {
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

  public shared ({ caller }) func sendMessage(teamKey : Text, username : Text, message : Text) : async ResultVoid {
    let team = switch (Team.get(db.teams, teamKey, caller, true)) {
      case (#ok(t)) t;
      case (#err(e)) return #err(e);
    };
    let ?id = User.getPrincipal(db.users, username) else return #err(#userNotFound);
    let true = Friend.isConnected(team.friends, caller, id) else return #err(#notAFriend);

    Chat.sendMessage(messageDB, caller, id, message);

    return #ok;
  };

  public shared query ({ caller }) func getMessages(teamKey : Text, username : Text) : async ResultMessages {
    let team = switch (Team.get(db.teams, teamKey, caller, true)) {
      case (#ok(t)) t;
      case (#err(e)) return #err(e);
    };
    let ?id = User.getPrincipal(db.users, username) else return #err(#userNotFound);
    let true = Friend.isConnected(team.friends, caller, id) else return #err(#notAFriend);

    let msgs = Chat.getMessages(messageDB, caller, id);
    return #ok(msgs);
  };

  public shared ({ caller }) func markMessageRead(teamKey : Text, username : Text) : async ResultNat {
    let team = switch (Team.get(db.teams, teamKey, caller, true)) {
      case (#ok(t)) t;
      case (#err(e)) return #err(e);
    };
    let ?other = User.getPrincipal(db.users, username) else return #err(#userNotFound);
    let true = Friend.isConnected(team.friends, caller, other) else return #err(#notAFriend);

    let unread = Chat.markRead(messageDB, caller, other);
    return #ok(unread);
  };

  func assertPermission(caller : Principal, permission : AdminPermission) {
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

    let team = switch (Team.get(db.teams, teamKey, caller, true)) {
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

    let team = switch (Team.get(db.teams, teamKey, caller, false)) {
      case (#ok(t)) t;
      case (#err(e)) return Debug.trap("couldn't get team");
    };

    let all = Question.backup(team.questions);
    let withOffset = IterTools.skip(all, offset);
    let withLimit = IterTools.take(withOffset, limit);
    Iter.toArray(withLimit);
  };

  public shared ({ caller }) func setCategory(teamKey : Text, data : [{ questionId : Nat; category : Text }]) : async ResultVoid {
    assertAdmin(caller);

    let team = switch (Team.get(db.teams, teamKey, caller, false)) {
      case (#ok(t)) t;
      case (#err(e)) return Debug.trap("couldn't get team");
    };

    for (d in data.vals()) {
      Question.setCategory(team.questions, d.questionId, d.category);
    };

    return #ok;
  };

  public shared ({ caller }) func airdrop(user : Text, tokens : Int) : async ResultVoid {
    assertAdmin(caller);

    let ?p = User.getPrincipal(db.users, user) else return #err(#userNotFound);

    switch (User.reward(db.users, #custom(tokens), p)) {
      case (#ok(_)) #ok;
      case (#err(e)) #err(e);
    };
  };

  public shared ({ caller }) func cleanup(teamKey : Text, mode : Nat) : async Result<Text> {
    assertAdmin(caller);

    let ?team = Map.get(db.teams, thash, teamKey) else return #err(#teamNotFound);

    switch (mode) {
      case (1) {
        let members = Set.toArray(team.members);
        for (m in members.vals()) {
          if (Principal.isAnonymous(m)) {
            Set.delete(team.members, phash, m);
          };
        };
        return #ok("done: remove anonymous principals");
      };
      case (n) {
        return #ok("Not implemented: mode " # Nat.toText(n));
      };
    };

  };

  public shared ({ caller }) func createTestData(teamKey : Text, questions : Nat, users : Nat) : async Nat {
    assertAdmin(caller);

    if (not Text.startsWith(teamKey, #text "test_")) Debug.trap("");

    let team = switch (Team.get(db.teams, teamKey, caller, false)) {
      case (#ok(t)) t;
      case (#err(e)) return Debug.trap("couldn't get team");
    };

    let res = User.add(db.users, "admin", "test user", "admin@allkinds", caller);

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
      let res = User.add(db.users, name, "test user", name # "@allkinds", principal);
      switch (res) {
        case (#ok(_)) {};
        case (#err(error)) {
          Debug.trap(debug_show (error) # " when creating user " # name);
        };
      };

      let res2 = Team.addMember(db.teams, teamKey, team.invite, principal, null);
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
