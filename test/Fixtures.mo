import Principal "mo:base/Principal";
import Iter "mo:base/Iter";
import Nat "mo:base/Nat";
import Nat8 "mo:base/Nat8";
import Text "mo:base/Text";
import Prng "mo:prng";
import User "../src/backend/User";
import Nat64 "mo:base/Nat64";
import Buffer "mo:base/Buffer";
import Array "mo:base/Array";
/// This file contains all test data that is too bulky to include directly into the tests


type User = User.User;

class Generator() {

  var random = Prng.SFC64a(); // insecure random numbers

  func flag(): Bool = random.next() % 2 == 0;
  func opt<T>(val: T): ?T = if(flag()) ?val else null;
  func either<T>(a: T, b: T): T =  if(flag()) a else b;
  func nat<T>(min: Nat, max: Nat): Nat = Nat64.toNat(random.next()) % (max - min) + min;
  func arr<T>(len: Nat, fn: () -> T): [T] {
    Array.tabulate(len, func (i: Nat): T = fn());
  };

  public func principal(n : Nat) : Principal = Principal.fromBlob(Text.encodeUtf8(Nat.toText(n)));


  public func user(n : Nat) : User {
    random.init(Nat64.fromIntWrap(n)); // make randomness deterministic

    {
      id = principal(n);
      username = "user" # Nat.toText(n);
      created = 1234567890_1000_1000;
      age = (opt<Nat8>(23), flag());
      about = (opt<Text>("about"), flag()); 
      gender = (opt(either<User.Gender>(#male, #female)), flag());
      picture = (null, flag());
      points = nat(0, 1000);
      socials = arr<(User.Social, User.IsPublic)>(nat(0, 2), func () = ({network= #email; handle= "user@test"}, flag()));
    };
  };
};
