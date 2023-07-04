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
import Int "mo:base/Int";
import Error "Error";
import Iter "mo:base/Iter";
import Debug "mo:base/Debug";
import Nat8 "mo:base/Nat8";

module {

  public type IsPublic = Bool;
  let YEAR = 31_556_952_000_000_000; // average length of a year: 365.2425 * 24 * 60 * 60* 1000 * 1000 * 1000

  type Time = Time.Time;
  type Map<K, V> = Map.Map<K, V>;
  type Result<T, E> = Result.Result<T, E>;
  type Iter<T> = Iter.Iter<T>;
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
    info = Map.new<Principal, User>(phash);
    byUsername = Map.new<Text, Principal>(thash);
  };

  public func backup(users : UserDB) : Iter<(Principal, User)> {
    Map.entries(users.info);
  };

  /// Information about a user.
  /// This contains private data and should not be returned to other users directly
  /// see UserInfo for non sensitive information
  public type User = {
    username : Text;
    created : Time;
    about : (?Text, IsPublic);
    gender : (?Gender, IsPublic);
    birth : (?Time, IsPublic);
    socials : [(Social, IsPublic)]; // contains email or social media links
    points : Nat;
    picture : (?Blob, IsPublic);
  };

  /// Public info about a user
  public type UserInfo = {
    username : Text;
    about : ?Text;
    gender : ?Gender;
    birth : ?Time;
    socials : [Social];
    picture : ?Blob;
  };

  public type Gender = {
    #Male;
    #Female;
    #Queer;
    #Other;
  };

  public type Social = {
    network : SocialNetwork;
    handle : Text;
    //verification: {link: Text, status: {#pending; #verified; #failed})
  };

  public type SocialNetwork = {
    #distrikt;
    #dscvr;
    #twitter;
    #mastodon;
    #email;
    #phone;
  };

  public type UserFilter = {
    minBirth : Time;
    maxBirth : Time;
    gender : ?Gender;
  };

  public func createFilter(minAge : Nat8, maxAge : Nat8, gender : ?Gender) : UserFilter {
    if (minAge > maxAge) Debug.trap("Invalid age");
    if (maxAge > 150) Debug.trap("Invalid maxAge");
    // TODO: limit minimal minAge?

    // TODO: calculate exact time with consideration of leap years
    let minBirth = Time.now() - (Nat8.toNat(maxAge) * YEAR);
    let maxBirth = Time.now() - (Nat8.toNat(minAge) * YEAR);

    { minBirth; maxBirth; gender };
  };

  public func add(users : UserDB, username : Text, id : Principal) : Result<User, Error> {
    if (Principal.isAnonymous(id)) return #err(#notLoggedIn);
    let null = get(users, id) else return #err(#alreadyRegistered);
    let true = validateName(username) else return #err(#validationError);
    let null = getByName(users, username) else return #err(#nameNotAvailable);

    let user = create(username);
    Map.set(users.info, phash, id, user);
    Map.set(users.byUsername, thash, username, id);
    #ok(user);
  };

  public func get(users : UserDB, id : Principal) : ?User {
    Map.get(users.info, phash, id);
  };

  public func getPrincipal(users : UserDB, name : Text) : ?Principal {
    Map.get(users.byUsername, thash, name);
  };

  public func getByName(users : UserDB, name : Text) : ?User {
    let ?id = getPrincipal(users, name) else return null;
    get(users, id);
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
      created = u.created; // can't be changed by user
      about = user.about;
      gender = user.gender;
      birth = user.birth;
      socials = user.socials;
      points = u.points; // can't be changed by user
      picture = user.picture;
    };

    Map.set(users.info, phash, id, newUser);

    #ok newUser;
  };

  public func find(users : UserDB, filter : UserFilter) : Iter<(Principal, User)> {
    Iter.filter<(Principal, User)>(Map.entries(users.info), func(_, u) = matches(u, filter));
  };

  func matches(user : User, filter : UserFilter) : Bool {
    switch (filter.gender) {
      case (null) {};
      case (?gender) {
        if ((?gender, true) != user.gender) return false;
      };
    };

    let (?birth, _) = user.birth else return true;
    if (birth < filter.minBirth) return false;
    if (birth > filter.maxBirth) return false;
    return true;
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

    let points = u.points : Int + amount;

    // check if the user can pay
    if (points < 0) return #err(#insufficientFunds);

    #ok(Int.abs(points));
  };

  public func reward(users : UserDB, action : RewardableAction, id : Principal) : Result<User, Error> {
    let ?u = get(users, id) else return #err(#notRegistered);

    let amount : Int = rewardSize(action);

    let points = u.points : Int + amount;

    // check if the user can pay
    if (points < 0) return #err(#insufficientFunds);

    let newUser : User = {
      username = u.username;
      created = u.created;
      about = u.about;
      gender = u.gender;
      birth = u.birth;
      socials = u.socials;
      points = Int.abs(points); // only this changes here
      picture = u.picture;
    };

    Map.set(users.info, phash, id, newUser);

    #ok newUser;
  };

  func create(username : Text) : User {
    {
      username;
      created = Time.now();
      about = (null, true);
      gender = (null, true);
      birth = (null, true);
      socials = [];
      points = 100;
      picture = (null, true);
    };
  };

  public func filterUserInfo(user : User) : UserInfo {
    let info : UserInfo = {
      username = user.username;
      about = checkPublic(user.about);
      gender = checkPublic(user.gender);
      birth = checkPublic(user.birth);
      socials = filterPublic(user.socials);
      picture = checkPublic(user.picture);
    };
  };

  //returns user info opt property if not undefined and public viewable
  func checkPublic<T>(prop : (?T, IsPublic)) : (?T) {
    switch (prop) {
      case (null, _) { null };
      case (?_, false) { null };
      case (?x, true) { ?x };
    };
  };

  func filterPublic<T>(props : [(T, IsPublic)]) : [T] {
    Array.mapFilter<(T, IsPublic), T>(
      props,
      func(t, pub) = if pub { ?t } else { null },
    );
  };

};
