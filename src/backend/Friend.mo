import Principal "mo:base/Principal";
import Map "mo:map/Map";
import Result "mo:base/Result";
import Option "mo:base/Option";
import Error "Error";
import Iter "mo:base/Iter";

module {

  type Map<K, V> = Map.Map<K, V>;
  type Result<K, V> = Result.Result<K, V>;
  type Error = Error.Error;
  type Iter<T> = Iter.Iter<T>;

  public type FriendDB = Map<Principal, UserFriends>;
  type UserFriends = Map<Principal, FriendStatus>;

  let { phash } = Map;

  public func emptyDB() : FriendDB = Map.new<Principal, UserFriends>(phash);

  public type FriendStatus = {
    #requestSend;
    #requestReceived;
    #connected;
    #requestIgnored;
    #rejectionSend;
    #rejectionReceived;
  };

  public func request(friends : FriendDB, sender : Principal, recipient : Principal) : Result<(), Error> {
    let senderFriends = getFriends(friends, sender);
    let recipientFriends = getFriends(friends, sender);

    let senderStatus = getFriend(senderFriends, recipient);
    let receipientStatus = getFriend(recipientFriends, sender);

    switch ((senderStatus, receipientStatus)) {
      case (null, null) {
        // send a new request
        Map.set(senderFriends, phash, recipient, #requestSend);
        Map.set(recipientFriends, phash, sender, #requestReceived);
      };
      case (?(#requestReceived), ?(#requestSend)) {
        // other user already requested
        Map.set(senderFriends, phash, recipient, #connected);
        Map.set(recipientFriends, phash, sender, #connected);
      };
      case (?(#connected), ?(#connected)) {
        // already connected
        return #ok;
      };
      case (_, _) {
        return #err(#friendRequestAlreadySend);
      };
    };

    #ok;
  };

  public func get(friends : FriendDB, user : Principal) : Iter<(Principal, FriendStatus)> {
    Map.entries(getFriends(friends, user));
  };

  // Get map of friend status or create an empty map
  func getFriends(friends : FriendDB, user : Principal) : UserFriends {
    Option.get(
      Map.get(friends, phash, user),
      Map.new<Principal, FriendStatus>(phash),
    );
  };

  func getFriend(friends : UserFriends, user : Principal) : ?FriendStatus {
    Map.get(friends, phash, user);
  }

};
