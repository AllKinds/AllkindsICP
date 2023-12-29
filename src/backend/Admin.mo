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
  type Map<K, V> = Map.Map<K, V>;
  let { thash; phash } = Map;

  public type AdminDB = Map<Principal, Permissions>;

  public type Permissions = {
    createTeam : Bool;
    suspendUser : Bool;
  };

  let noPermissions = {
    createTeam = false;
    suspendUser = false;
  };

  public func getPermissions(admins : AdminDB, user : Principal) : Permissions {
    let ?permissions = Map.get(admins, phash, user) else return noPermissions;
    permissions;
  };

  public func emptyDB() : AdminDB = Map.new<Principal, Permissions>();

  public func setAdmin(admins : AdminDB, user : Principal, permissions : Permissions) {
    ignore Map.put(admins, phash, user, permissions);
  };
};
