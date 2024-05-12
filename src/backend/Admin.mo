import Principal "mo:base/Principal";
import Map "mo:map/Map";
import Iter "mo:base/Iter";
import Types "types/Types";

module {
  type Iter<T> = Iter.Iter<T>;
  type Map<K, V> = Map.Map<K, V>;
  type AdminDB = Types.AdminDB;
  type Permission = Types.AdminPermission;
  type Permissions = Types.AdminPermissions;
  let { phash } = Map;

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
