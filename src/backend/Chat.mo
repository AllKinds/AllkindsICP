import Time "mo:base/Time";
import Hash "mo:base/Hash";
import Principal "mo:base/Principal";
import Array "mo:base/Array";
import Debug "mo:base/Debug";
import Map "mo:map/Map";

import Buffer "mo:StableBuffer/StableBuffer";
import Types "Types";

module {
  type Time = Time.Time;
  type Map<K, V> = Map.Map<K, V>;

  type Message = Types.Message;
  type Messages = Types.Messages;
  type MessageDB = Types.MessageDB;
  type Key = Types.MessageKey;

  public func emptyDB() : MessageDB = Map.new();

  public func sendMessage(db : MessageDB, from : Principal, to : Principal, content : Text) : () {
    let msgs = getMsgs(db, from, to);
    let sender = from < to;

    let msg : Message = {
      sender;
      content;
      time = Time.now();
    };

    Buffer.add(msgs, msg);
    Debug.print(debug_show db);
  };

  func keyFromPrincipals(a : Principal, b : Principal) : Key {
    if (a > b) return (b, a);
    return (a, b);
  };

  func keyHash(key : Key) : Hash.Hash {
    let (a, b) = key;
    return Principal.hash(a) + Principal.hash(b);
  };

  func keyEqual(a : Key, b : Key) : Bool {
    a == b;
  };

  let khash : Map.HashUtils<Key> = (keyHash, keyEqual);

  public func getMsgs(db : MessageDB, from : Principal, to : Principal) : Messages {
    let key = keyFromPrincipals(from, to);

    let msgs = switch (Map.get<Key, Messages>(db, khash, key)) {
      case (?messages) messages;
      case (null) {
        // instert a new one if none is found
        let buf = Buffer.init<Message>();
        Map.set(db, khash, key, buf);
        buf;
      };
    };

    return msgs;
  };

  public func getMessages(db : MessageDB, from : Principal, to : Principal) : [Message] {
    let msgs = getMsgs(db, from, to);
    if (from < to) {
      return Buffer.toArray(msgs);
    };
    // invert sender before returning
    return Array.map<Message, Message>(Buffer.toArray(msgs), func(m) = { sender = not m.sender; content = m.content; time = m.time });
  };

};
