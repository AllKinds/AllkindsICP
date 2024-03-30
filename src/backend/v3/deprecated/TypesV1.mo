import Map "mo:map/Map";
module emptyAdminDBvemptyAdminDBv11 {
  type Map<K, V> = Map.Map<K, V>;

  public type AdminDB = Map<Principal, Permissions>;
  public type Permissions = { createTeam : Bool; suspendUser : Bool };
  public func emptyAdminDBv1() : AdminDB = Map.new<Principal, Permissions>();
};
