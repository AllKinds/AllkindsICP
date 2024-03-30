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

import Error "../Error";

module {

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

  func emptyUserDB() : UserDB = {
    info = Map.new<Principal, User>();
    byUsername = Map.new<Text, Principal>();
  };

  func emptyTeamDB() : TeamDB = Map.new<Text, Team>();

  public func emptyAdminDB() : AdminDB = Map.new<Principal, AdminPermissions>();

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
    team : Text;
    event : {
      #friendRequests : Nat;
      #newQuestions : Nat;
      #rewards : Nat;
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
};
