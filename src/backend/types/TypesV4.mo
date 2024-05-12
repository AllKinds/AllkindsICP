import Int "mo:base/Int";
import Iter "mo:base/Iter";
import Principal "mo:base/Principal";
import Result "mo:base/Result";
import Text "mo:base/Text";
import Time "mo:base/Time";
import Trie "mo:base/Trie";
import Map "mo:map/Map";
import Set "mo:map/Set";
import StableBuffer "mo:StableBuffer/StableBuffer";
import Prng "mo:prng";
import Nat32 "mo:base/Nat32";

import Error "../Error";
import TypesV1 "TypesV3";

module {

  let { thash; phash } = Map;

  /// ========
  /// DB TYPES
  /// ========

  public type DB = {
    users : UserDB;
    teams : TeamDB;
  };

  public type AdminDB = Map<Principal, AdminPermissions>;

  public func emptyDB() : DB = {
    users = emptyUserDB();
    teams = emptyTeamDB();
  };

  public func migrateV1(v1 : TypesV1.DB) : DB = {
    users = v1.users;
    teams = migrateTeamDBV1(v1.teams);
  };

  public func emptyUserDB() : UserDB = {
    info = Map.new<Principal, User>();
    byUsername = Map.new<Text, Principal>();
  };

  func emptyTeamDB() : TeamDB = Map.new<Text, Team>();

  func migrateTeamDBV1(v1 : TypesV1.TeamDB) : TeamDB {
    Map.map<Text, TypesV1.Team, Team>(v1, thash, func(_id, team) = migrateTeamV1(team));
  };

  public func emptyAdminDB() : AdminDB = Map.new<Principal, AdminPermissions>();

  func migrateTeamV1(v1 : TypesV1.Team) : Team {
    let seed1 = Text.hash(v1.info.name);
    {
      info = v1.info;
      invite = v1.invite;
      userInvites : UserInviteDB = invitesFromMembers(v1.members, seed1);
      members = v1.members;
      admins = v1.admins;

      questions = v1.questions;
      answers = v1.answers;
      skips = v1.skips;
      friends = v1.friends;

      userSettings : TeamUserSettingsDB = Map.new();
    };
  };

  func invitesFromMembers(members : Set<Principal>, seed1 : Nat32) : UserInviteDB {
    let invites : UserInviteDB = Map.new();
    let insecureRandom = Prng.SFC32a(); // insecure random numbers

    for (member : Principal in Set.keys(members)) {
      let seed : Nat32 = Principal.hash(member);
      insecureRandom.init(seed1 ^ seed);
      let invite = Nat32.toText(insecureRandom.next());
      Map.set(invites, phash, member, invite);
    };

    return invites;
  };

  /// ============
  /// COMMON TYPES
  /// ============
  type Time = Time.Time;
  type Map<K, V> = Map.Map<K, V>;
  type Iter<T> = Iter.Iter<T>;
  type Set<T> = Set.Set<T>;
  type Buffer<T> = StableBuffer.StableBuffer<T>;
  type Error = Error.Error;
  public type Result<T> = Result.Result<T, Error>;

  /// ==========
  /// USER TYPES
  /// ==========

  /// Actions that might modify the balance of the user
  public type RewardableAction = {
    #createQuestion;
    #createAnswer : Nat; // boost
    #findMatch;
    #custom : Int;
  };

  /// Information about a user.
  /// This contains private data and should not be returned to other users directly
  /// see UserInfo for non sensitive information
  public type User = {
    username : Text;
    displayName : Text;
    created : Time;
    about : Text;
    contact : Text; // contains email or social media links
    picture : ?Blob;
    stats : UserStats;
  };

  public type UserStats = {
    points : Nat;
    asked : Nat;
    answered : Nat;
    boosts : Nat;
  };

  /// Public info about a user
  public type UserInfo = {
    username : Text;
    displayName : Text;
    about : Text;
    contact : Text;
    picture : ?Blob;
  };

  public type Notification = {
    team : [Text];
    event : {
      #friendRequests : Nat;
      #newQuestions : Nat;
      #rewards : Nat;
      #chat : { unread : Nat; user : Text; latest : Message };
    };
  };

  public type UserPermissions = {
    user : User;
    permissions : AdminPermissions;
    notifications : [Notification];
  };

  public type UserNotifications = {
    user : User;
    notifications : [Notification];
  };

  public type UserDB = {
    info : Map<Principal, User>;
    byUsername : Map<Text, Principal>;
  };

  /// ==============
  /// Question TYPES
  /// ==============

  public type QuestionDB = Buffer<StableQuestion>; // TODO: consider other data structure as buffer can have bad worst case performance due to resizing
  public type UserAnswers = Trie.Trie<QuestionID, Answer>;
  public type UserSkips = Trie.Trie<QuestionID, Skip>;
  public type AnswerDB = Map<Principal, UserAnswers>;
  public type SkipDB = Map<Principal, UserSkips>;

  public type QuestionID = Nat;

  // Color indicates optional background color for the question
  public type StableQuestion = {
    id : QuestionID;
    created : Time;
    creator : Principal;
    question : Text;
    color : Text;
    points : Int; // type Int because question points should be able to go negative
    showCreator : Bool;
    hidden : Bool;
  };

  // Question that can be returned to the frontend
  public type Question = {
    id : QuestionID;
    created : Time;
    creator : ?Text;
    question : Text;
    color : Text;
    points : Int; // type Int because question points should be able to go negative
    deleted : Bool;
  };

  public type Answer = {
    created : Time;
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

  public type QuestionStats = {
    question : Question;
    answers : Nat;
    yes : Nat;
    no : Nat;
    skips : Nat;
    boosts : Nat;
  };

  public type Dismissed = {
    question : Nat;
  };

  /// ============
  /// FRIEND Types
  /// ============

  public type FriendDB = Map<Principal, UserFriends>;
  public type UserFriends = Map<Principal, FriendStatus>;
  public type FriendStatus = {
    #requestSend;
    #requestReceived;
    #connected;
    #rejectionSend;
    #rejectionReceived;
  };

  /// ==========
  /// Team Types
  /// ==========

  public type Team = {
    info : TeamInfo;
    invite : Text; // secret to prevent unauthorized users from joining the team
    userInvites : UserInviteDB;
    members : Set<Principal>;
    admins : Set<Principal>;

    questions : QuestionDB;
    answers : AnswerDB;
    skips : SkipDB;
    friends : FriendDB;
    userSettings : TeamUserSettingsDB;
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
    userInvite : ?Text;
  };

  public type TeamStats = {
    users : Nat;
    questions : Nat;
    answers : Nat;
    connections : Nat;
  };

  public type TeamUserSettings = {
    stared : [QuestionID];
    invitedBy : ?Principal;
  };

  public type Permissions = { isMember : Bool; isAdmin : Bool };

  public type TeamDB = Map<Text, Team>;

  public type TeamUserSettingsDB = Map<Principal, TeamUserSettings>;

  public type UserInviteDB = Map<Principal, Text>;

  /// ===========
  /// Admin Types
  /// ===========

  public type AdminPermissions = {
    suspendUser : Bool;
    editUser : Bool;
    createTeam : Bool;
    listAllTeams : Bool;
    becomeTeamMember : Bool; // without invite
    becomeTeamAdmin : Bool; // can remove users, edit questions or delete the team
    createBackup : Bool;
    restoreBackup : Bool;
  };

  public type AdminPermission = {
    #suspendUser;
    #editUser;
    #createTeam;
    #listAllTeams;
    #becomeTeamMember;
    #becomeTeamAdmin;
    #createBackup;
    #restoreBackup;
    #all;
  };

  // ==========
  // Chat Types
  // ==========

  public type Message = {
    content : Text;
    time : Time;
    sender : Bool;
  };

  public type MessageKey = (Principal, Principal);

  public type Messages = Buffer<Message>;
  public type ChatStatus = { unread : Nat };
  public type MessageDbEntry = {
    messages : Messages;
    status1 : ChatStatus;
    status2 : ChatStatus;
  };
  public type MessageDB = Map<MessageKey, MessageDbEntry>;
  public func emptyMessageDB() : MessageDB = Map.new();

};
