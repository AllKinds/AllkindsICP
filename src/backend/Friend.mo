import Principal "mo:base/Principal";
import Map "mo:map/Map";
module {

  type Map<K, V> = Map.Map<K, V>;

  public type FriendDB = Map<Principal, Map<Principal, FriendStatus>>;

  let { phash } = Map;

  public func emptyDB() : FriendDB = Map.new<Principal, Map<Principal, FriendStatus>>(phash);

  public type FriendStatus = {
    #Requested; //status of requested contact in msg.caller friendlist
    #Waiting; //status of msg.caller in the requested contact friendlist
    #Approved; //status of both users after
    //could be added upon and improved (REQ/WAIT might be too confusing, but this makes it ez to track who requested)
    //maybe change req/wait to send/requests (as its similar to ui)
  };

  //obj instead of tuple , bcs it should be expanded in future
  public type Friend = {
    account : Principal;
    status : ?FriendStatus;
  };

  public type FriendList = [Friend];

};
