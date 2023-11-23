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
  let { thash; phash } = Map;

  type Error = Error.Error;

  public type RewardableAction = {
    #createQuestion;
    #createAnswer : Nat; // boost
    #findMatch;
    #custom : Int;
  };

  public type UserDB = {
    info : Map<Principal, StableUser>;
    byUsername : Map<Text, Principal>;
  };

  public func emptyDB() : UserDB = {
    info = Map.new<Principal, StableUser>(phash);
    byUsername = Map.new<Text, Principal>(thash);
  };

  public func backup(users : UserDB) : Iter<(Principal, User)> {
    let all : Iter<(Principal, StableUser)> = Map.entries(users.info);
    Iter.map<(Principal, StableUser), (Principal, User)>(
      all,
      func entry = TupleHelper.mapSecond(entry, stableToUser),
    );
  };

  /// Information about a user.
  /// This contains private data and should not be returned to other users directly
  /// see UserInfo for non sensitive information
  public type User = {
    username : Text;
    created : Time;
    about : (?Text, IsPublic);
    gender : (?Gender, IsPublic);
    age : (?Nat8, IsPublic);
    socials : [(Social, IsPublic)]; // contains email or social media links
    points : Nat;
    picture : (?Blob, IsPublic);
  };

  type StableUser = {
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
    age : ?Nat8;
    socials : [Social];
    picture : ?Blob;
  };

  public type Gender = {
    #male;
    #female;
    #queer;
    #other;
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

  func stableToUser(user : StableUser) : User {
    {
      username = user.username;
      created = user.created;
      about = user.about;
      gender = user.gender;
      age = TupleHelper.mapFirst<?Time, IsPublic, ?Nat8>(
        user.birth,
        func x = Option.chain(x, toAge),
      );
      socials = user.socials;
      picture = user.picture;
      points = user.points;
    };
  };

  public func createFilter(minAge : Nat8, maxAge : Nat8, gender : ?Gender) : UserFilter {
    if (minAge > maxAge) Debug.trap("Invalid age");
    if (maxAge > 150) Debug.trap("Invalid maxAge");

    let minBirth = toBirth(maxAge) - YEAR;
    let maxBirth = toBirth(minAge);

    { minBirth; maxBirth; gender };
  };

  public func add(users : UserDB, username : Text, contact : Text, id : Principal) : Result<User, Error> {
    if (Principal.isAnonymous(id)) return #err(#notLoggedIn);
    let null = get(users, id) else return #err(#alreadyRegistered);
    let true = validateName(username) else return #err(#validationError);
    let null = getByName(users, username) else return #err(#nameNotAvailable);

    let user = create(username, contact);
    let lookupKey = TextHelper.toLower(username);
    Map.set(users.info, phash, id, user);
    Map.set(users.byUsername, thash, lookupKey, id);
    #ok(stableToUser(user));
  };

  func getStable(users : UserDB, id : Principal) : ?StableUser {
    Map.get(users.info, phash, id);
  };

  public func get(users : UserDB, id : Principal) : ?User {
    Option.map(getStable(users, id), stableToUser);
  };

  public func getPrincipal(users : UserDB, username : Text) : ?Principal {
    let lookupKey = TextHelper.toLower(username);
    Map.get(users.byUsername, thash, lookupKey);
  };

  func getByName(users : UserDB, name : Text) : ?StableUser {
    let ?id = getPrincipal(users, name) else return null;
    getStable(users, id);
  };

  public func getInfo(users : UserDB, id : Principal, showNonPublic : Bool) : ?UserInfo {
    let ?u = getStable(users, id) else return null;
    ?filterUserInfo(u, showNonPublic);
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
    let newUser : StableUser = {
      username = u.username; // can't be changed by user
      created = u.created; // can't be changed by user
      about = user.about;
      gender = user.gender;
      birth = TupleHelper.mapFirst<?Nat8, IsPublic, ?Time>(user.age, func x = Option.map(x, toBirth));
      socials = user.socials;
      points = u.points; // can't be changed by user
      picture = user.picture;
    };

    Map.set(users.info, phash, id, newUser);

    #ok(stableToUser(newUser));
  };

  public func find(users : UserDB, filter : UserFilter) : Iter<(Principal, User)> {
    let filtered = Iter.filter<(Principal, StableUser)>(Map.entries(users.info), func(_, u) = matches(u, filter));
    Iter.map<(Principal, StableUser), (Principal, User)>(filtered, func x = TupleHelper.mapSecond(x, stableToUser));
  };

  func matches(user : StableUser, filter : UserFilter) : Bool {
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
    let ?u = getStable(users, id) else return #err(#notRegistered);

    let amount : Int = rewardSize(action);

    let points = u.points : Int + amount;

    // check if the user can pay
    if (points < 0) return #err(#insufficientFunds);

    let newUser : StableUser = {
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

    #ok(stableToUser(newUser));
  };

  func create(username : Text, contact : Text) : StableUser {
    {
      username;
      created = Time.now();
      about = (null, true);
      gender = (null, true);
      birth = (null, true);
      socials = [({ network = #email; handle = contact }, false)];
      points = 100;
      picture = (null, true);
    };
  };

  public func filterUserInfo(user : StableUser, showNonPublic : Bool) : UserInfo {
    let info : UserInfo = {
      username = user.username;
      about = checkPublic(user.about, showNonPublic);
      gender = checkPublic(user.gender, showNonPublic);
      age = Option.chain<Time, Nat8>(checkPublic(user.birth, showNonPublic), toAge);
      socials = filterPublic(user.socials, showNonPublic);
      picture = checkPublic(user.picture, showNonPublic);
    };
  };

  //returns user info opt property if not undefined and public viewable
  func checkPublic<T>((t : ?T, pub : IsPublic), showNonPublic : Bool) : (?T) {
    if (pub or showNonPublic) { t } else { null };
  };

  func filterPublic<T>(props : [(T, IsPublic)], showNonPublic : Bool) : [T] {
    Array.mapFilter<(T, IsPublic), T>(
      props,
      func(t, pub) = if (pub or showNonPublic) { ?t } else { null },
    );
  };

  func toAge(birth : Time) : ?Nat8 {
    let diff = Time.now() - birth;
    if (diff < 0) return null;
    let age = diff / YEAR;
    if (age > Nat8.toNat(Configuration.user.maxAge)) return ?Configuration.user.maxAge;

    // TODO: calculate exact time with consideration of leap years
    ?Nat8.fromIntWrap(age);
  };

  func toBirth(age : Nat8) : Time {
    // TODO: calculate exact time with consideration of leap years
    Time.now() - (Nat8.toNat(age) * YEAR);
  };

  func setAge((ageOrBirth, isPublic) : (?Int, Bool)) : (?Time, Bool) {
    switch (ageOrBirth) {
      case (null)(null, isPublic);
      case (?number) {
        if (number <= 200 and number >= 0) {
          // This is overlapping with the possible time stamps
          // chance of collision is very small: 200 nanoseconds per year,
          // so no real risk, but it's ugly
          (?toBirth(Nat8.fromIntWrap(number)), isPublic);
        } else if (number < Time.now() and number > toBirth(200)) {
          (?number, isPublic);
        } else { (null, isPublic) };
      };
    };
  };

};
