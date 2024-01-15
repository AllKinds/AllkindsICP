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
  type Iter<T> = Iter.Iter<T>;
  type Map<K, V> = Map.Map<K, V>;
  let { thash; phash } = Map;

  public type AdminDB = Map<Principal, Permissions>;

  public type Permissions = {
    suspendUser : Bool;
    editUser : Bool;
    createTeam : Bool;
    listAllTeams : Bool;
    becomeTeamMember : Bool; // without invite
    becomeTeamAdmin : Bool; // can remove users, edit questions or delete the team
    createBackup : Bool;
    restoreBackup : Bool;
  };

  public type Permission = {
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

  let noPermissions = {
    suspendUser = false;
    editUser = false;
    createTeam = true;
    listAllTeams = false;
    becomeTeamMember = false;
    becomeTeamAdmin = false;
    createBackup = false;
    restoreBackup = false;
  };

  public let creatorPermissions = {
    editUser = false;
    suspendUser = false;
    createTeam = true;
    listAllTeams = false;
    becomeTeamMember = false;
    becomeTeamAdmin = false;
    createBackup = false;
    restoreBackup = false;
  };

  public let moderatorPermissions = {
    editUser = false;
    suspendUser = true;
    createTeam = true;
    listAllTeams = true;
    becomeTeamMember = true;
    becomeTeamAdmin = false;
    createBackup = false;
    restoreBackup = false;
  };

  public let adminPermissions = {
    editUser = true;
    suspendUser = true;
    createTeam = true;
    listAllTeams = true;
    becomeTeamMember = true;
    becomeTeamAdmin = true;
    createBackup = true;
    restoreBackup = true;
  };

  public func getPermissions(admins : AdminDB, user : Principal) : Permissions {
    let ?permissions = Map.get(admins, phash, user) else return noPermissions;
    permissions;
  };

  public func emptyDB() : AdminDB = Map.new<Principal, Permissions>();

  public func setPermissions(admins : AdminDB, user : Principal, permissions : Permissions) {
    ignore Map.put(admins, phash, user, permissions);
  };

  public func list(admins : AdminDB) : Iter<(Principal, Permissions)> {
    Map.entries(admins);
  };

  public func hasPermission(admins : AdminDB, user : Principal, permission : Permission) : Bool {
    if (Principal.isController(user)) return true;

    let ps = getPermissions(admins, user);
    switch (permission) {
      case (#editUser) { ps.editUser };
      case (#suspendUser) { ps.suspendUser };
      case (#createTeam) { ps.createTeam };
      case (#listAllTeams) { ps.listAllTeams };
      case (#becomeTeamMember) { ps.becomeTeamMember };
      case (#becomeTeamAdmin) { ps.becomeTeamAdmin };
      case (#createBackup) { ps.createBackup };
      case (#restoreBackup) { ps.createBackup };
      case (#all) { ps == adminPermissions };
    };
  };
};
