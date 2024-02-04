import List "mo:base/List";
import TrieMap "mo:base/TrieMap";
import Principal "mo:base/Principal";
import Time "mo:base/Time";
import Array "mo:base/Array";
import Result "mo:base/Result";
import Configuration "Configuration";
import Char "mo:base/Char";
import Text "mo:base/Text";
import Map "mo:map/Map";
import Set "mo:map/Set";
import Int "mo:base/Int";
import Error "Error";
import Iter "mo:base/Iter";
import Debug "mo:base/Debug";
import Nat8 "mo:base/Nat8";
import TextHelper "helper/TextHelper";
import Option "mo:base/Option";
import TupleHelper "helper/TupleHelper";
import StableBuffer "mo:StableBuffer/StableBuffer";

module {

  public type IsPublic = Bool;
  let YEAR = 31_556_952_000_000_000; // average length of a year: 365.2425 * 24 * 60 * 60* 1000 * 1000 * 1000

  type Time = Time.Time;
  type Map<K, V> = Map.Map<K, V>;
  type Result<T, E> = Result.Result<T, E>;
  type Iter<T> = Iter.Iter<T>;
  type Set<T> = Set.Set<T>;
  let { thash; phash } = Map;

  type Error = Error.Error;

  public type RewardableAction = {
    #createQuestion;
    #createAnswer : Nat; // boost
    #findMatch;
    #custom : Int;
  };

  public type UserDB = {
    info : Map<Principal, User>;
    byUsername : Map<Text, Principal>;
  };

  public func emptyDB() : UserDB = {
    info = Map.new<Principal, User>();
    byUsername = Map.new<Text, Principal>();
  };

  public func backup(users : UserDB) : Iter<(Principal, User)> {
    Map.entries(users.info);
  };

  public func list(users : UserDB) : Iter<(Principal, User)> {
    Map.entries(users.info);
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

  public type UserFilter = {};

  public func add(users : UserDB, displayName : Text, contact : Text, id : Principal) : Result<User, Error> {
    if (Principal.isAnonymous(id)) return #err(#notLoggedIn);
    let null = get(users, id) else return #err(#alreadyRegistered);

    let user = create(displayName, contact);

    let true = validateName(user.username) else return #err(#validationError);
    let null = getByName(users, user.username) else return #err(#nameNotAvailable);

    Map.set(users.info, phash, id, user);
    Map.set(users.byUsername, thash, user.username, id);
    #ok(user);
  };

  public func get(users : UserDB, id : Principal) : ?User {
    Map.get(users.info, phash, id);
  };

  public func getPrincipal(users : UserDB, username : Text) : ?Principal {
    let lookupKey = TextHelper.toLower(username);
    Map.get(users.byUsername, thash, lookupKey);
  };

  func getByName(users : UserDB, name : Text) : ?User {
    let ?id = getPrincipal(users, name) else return null;
    get(users, id);
  };

  public func getInfo(users : UserDB, id : Principal, showNonPublic : Bool) : ?UserInfo {
    let ?u = get(users, id) else return null;
    ?filterUserInfo(u);
  };

  func validateName(username : Text) : Bool {
    // Size must be in range
    if (username.size() < Configuration.user.minNameSize) return false;
    if (username.size() > Configuration.user.maxNameSize) return false;
    // Must start with an alphabetic char
    if (not Text.startsWith(username, #predicate(Char.isAlphabetic))) return false;
    // Must only contain alphabetic and numeric chars
    if (Text.contains(username, #predicate(func c = not (Char.isAlphabetic(c) or Char.isDigit(c))))) return false;

    // All checks passed
    return true;
  };

  public func update(users : UserDB, user : User, id : Principal) : Result<User, Error> {
    let ?u = get(users, id) else return #err(#notRegistered);
    let newUser : User = {
      username = u.username; // can't be changed by user
      displayName = user.displayName;
      created = u.created; // can't be changed by user
      about = user.about;
      contact = user.contact;
      picture = user.picture;
      stats = u.stats; // can't be changed by user
    };

    Map.set(users.info, phash, id, newUser);

    #ok(newUser);
  };

  public func find(users : UserDB, teamMembers : Set<Principal>) : Iter<(Principal, User)> {
    let principals = Set.keys(teamMembers);
    let iter = {
      next = func() : ?(Principal, User) {
        let ?p = principals.next() else return null;
        let ?u = Map.get(users.info, phash, p) else {
          // This should never happen and would likely be caused by a bug
          // in team member management (add non registered member) or in
          // user deletion (delete from users, but not from members)
          Debug.trap("Principal in teamMembers but not in users.");
        };
        return ?(p, u);
      };
    };
    //Map.entries(users.info);
  };

  /// Check how much an action is rewarded or costs
  /// costs are represented as negative rewards
  public func rewardSize(action : RewardableAction) : Int {
    switch (action) {
      case (#createQuestion) { Configuration.rewards.creatorReward };
      case (#createAnswer(boost)) {
        Configuration.rewards.answerReward +
        (boost * Configuration.rewards.boostReward);
      };
      case (#findMatch) { Configuration.rewards.queryReward };
      case (#custom(n)) { n };
    };
  };

  public func checkFunds(users : UserDB, action : RewardableAction, id : Principal) : Result<Nat, Error> {
    let ?u = get(users, id) else return #err(#notRegistered);

    let amount : Int = rewardSize(action);

    let points = u.stats.points : Int + amount;

    // check if the user can pay
    if (points < 0) return #err(#insufficientFunds);

    #ok(Int.abs(points));
  };

  public func reward(users : UserDB, action : RewardableAction, id : Principal) : Result<User, Error> {
    let ?u = get(users, id) else return #err(#notRegistered);

    let amount : Int = rewardSize(action);

    let points = u.stats.points : Int + amount;

    // check if the user can pay
    if (points < 0) return #err(#insufficientFunds);

    let newStats = setPoints(u.stats, Int.abs(points));

    let newUser = setStats(u, newStats);

    Map.set(users.info, phash, id, newUser);

    #ok(newUser);
  };

  let initStats : UserStats = {
    points = 100;
    asked = 0;
    answered = 0;
    boosts = 0;
  };

  func setStats(u : User, stats : UserStats) : User {
    return {
      username = u.username;
      displayName = u.displayName;
      created = u.created;
      about = u.about;
      contact = u.contact;
      picture = u.picture;
      stats; // only this is updated
    };
  };

  func setPoints(s : UserStats, points : Nat) : UserStats {
    return {
      points;
      answered = s.answered;
      asked = s.asked;
      boosts = s.boosts;
    };
  };

  func incrementAnswered(s : UserStats) : UserStats {
    return {
      points = s.points;
      answered = s.answered + 1;
      asked = s.asked;
      boosts = s.boosts;
    };
  };

  func incrementAsked(s : UserStats) : UserStats {
    return {
      points = s.points;
      answered = s.answered;
      asked = s.asked + 1;
      boosts = s.boosts;
    };
  };

  func incrementBoosts(s : UserStats) : UserStats {
    return {
      points = s.points;
      answered = s.answered;
      asked = s.asked;
      boosts = s.boosts + 1;
    };
  };

  public func increment(users : UserDB, what : { #answered; #asked; #boost }, id : Principal) : Result<User, Error> {
    let ?u = get(users, id) else return #err(#notRegistered);

    let newStats = switch (what) {
      case (#answered) { incrementAnswered(u.stats) };
      case (#asked) { incrementAsked(u.stats) };
      case (#boost) { incrementBoosts(u.stats) };
    };

    let newUser = setStats(u, newStats);

    Map.set(users.info, phash, id, newUser);

    #ok(newUser);
  };

  public func create(displayName : Text, contact : Text) : User {
    return {
      username = toUsername(displayName);
      displayName;
      created = Time.now();
      about = "";
      contact;
      picture = null;
      stats = initStats;
    };
  };

  func toUsername(displayName : Text) : Text {
    var first = true;
    Text.translate(
      displayName,
      func(c) {
        if (Char.isAlphabetic(c)) {
          first := false;
          TextHelper.charToLower(c);
        } else if (Char.isDigit(c)) {
          if (first) {
            first := false;
            "";
          } else {
            Text.fromChar(c);
          };
        } else {
          "";
        };
      },
    );
  };

  public func filterUserInfo(user : User) : UserInfo {
    let info : UserInfo = {
      username = user.username;
      displayName = user.displayName;
      about = user.about;
      contact = user.contact;
      picture = user.picture;
    };
  };
};
