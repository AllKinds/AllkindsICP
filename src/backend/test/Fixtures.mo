import Principal "mo:base/Principal";
import Iter "mo:base/Iter";
import Nat "mo:base/Nat";
import Nat8 "mo:base/Nat8";
import Text "mo:base/Text";
import Prng "mo:prng";
import Nat64 "mo:base/Nat64";
import Buffer "mo:base/Buffer";
import Array "mo:base/Array";
import Debug "mo:base/Debug";
import Time "mo:base/Time";
import TypesV3 "../types/TypesV3";
import Map "mo:map/Map";
import Set "mo:map/Set";
import StableBuffer "mo:StableBuffer/StableBuffer";
import Question "../v1/Question";
import Friend "../v1/Friend";
import Team "../v1/Team";
import User "../v1/User";
/// This file contains all test data that is too bulky to include directly into the tests

type User = TypesV3.User;

class Generator() {
  let { thash; phash } = Map;

  var insecureRandom = Prng.SFC64a(); // insecure random numbers

  func flag() : Bool = insecureRandom.next() % 2 == 0;
  func opt<T>(val : T) : ?T = if (flag()) ?val else null;
  func either<T>(a : T, b : T) : T = if (flag()) a else b;
  func nat<T>(min : Nat, max : Nat) : Nat = Nat64.toNat(insecureRandom.next()) % (max - min) + min;
  func arr<T>(len : Nat, fn : () -> T) : [T] {
    Array.tabulate(len, func(i : Nat) : T = fn());
  };

  public func principal(n : Nat) : Principal = Principal.fromBlob(Text.encodeUtf8(Nat.toText(n)));

  public func user(n : Nat) : User {
    insecureRandom.init(Nat64.fromIntWrap(n)); // make randomness deterministic

    let stats : TypesV3.UserStats = {
      answered = 1;
      asked = 2;
      boosts = 3;
      points = 4;
    };

    {
      id = principal(n);
      username = "user" # Nat.toText(n);
      displayName = "User " # Nat.toText(n);
      created = 1234567890_000_000;
      about = "about";
      contact = "contact";
      picture = null;
      stats;
    };
  };

  public func team() : TypesV3.Team {
    let info = {
      name = "test-team";
      about = "unit test team";
      logo = "" : Blob;
      listed = false;
    };
    //public func create(teams : TeamDB, key : Text, invite : Text, info : TeamInfo, admin : Principal) : Result<TeamInfo> {
    let team : TypesV3.Team = {
      info;
      invite = "test-invite";
      members = Set.new();
      admins = Set.make(phash, principal(0));
      questions = Question.emptyDB();
      answers = Question.emptyAnswerDB();
      skips = Question.emptySkipDB();
      friends = Friend.emptyDB();
    };

  };

  public func testDBv3() : TypesV3.DB {
    let admin = user(0);
    let adminP = principal(0);
    let member = user(1);
    let memberP = principal(1);
    let db = TypesV3.emptyDB();
    Map.set(db.users.info, phash, memberP, member);
    Map.set(db.users.byUsername, thash, member.username, memberP);
    Map.set(db.users.info, phash, adminP, admin);
    Map.set(db.users.byUsername, thash, admin.username, adminP);

    let null = Map.put(db.teams, thash, "test-team", team()) else Debug.trap("Team must not exist");

    return db;
  };

  public func createTestData(db : TypesV3.DB, teamKey : Text, questions : Nat, users : Nat) : TypesV3.DB {
    let caller = principal(0);

    let team = switch (Team.get(db.teams, teamKey, caller)) {
      case (#ok(t)) t;
      case (#err(_e)) return Debug.trap("couldn't get team");
    };

    let _res = User.add(db.users, "admin", "admin@allkinds", caller);

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

      let p = principal(i);
      let res = User.add(db.users, name, name # "@allkinds", p);
      switch (res) {
        case (#ok(_)) {};
        case (#err(error)) {
          Debug.trap(debug_show (error) # " when creating user " # name);
        };
      };

      let res2 = Team.addMember(db.teams, teamKey, team.invite, p);
      switch (res2) {
        case (#ok(_)) {};
        case (#err(error)) {
          Debug.trap(debug_show (error) # " when adding user " # name # " as a member");
        };
      };

      let qs = Question.unanswered(team.questions, team.answers, team.skips, p);
      for (q in qs) {
        randI += 1;
        let a : TypesV3.Answer = {
          question = q.id;
          answer = rand[randI % 256] == 0;
          weight = 1;
          created = Time.now();
        };
        ignore Question.putAnswer(team.answers, a, p);
      };
    };

    db;
  };
};
