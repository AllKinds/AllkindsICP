import Map "mo:map/Map";
module {
  type Map<K, V> = Map.Map<K, V>;

  public type AdminDB = Map<Principal, Permissions>;
  public type Permissions = { createTeam : Bool; suspendUser : Bool };
  public func emptyDB() : AdminDB = Map.new<Principal, Permissions>();
};
