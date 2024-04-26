import Time "mo:base/Time";
import Hash "mo:base/Hash";
import Principal "mo:base/Principal";
import Array "mo:base/Array";
import Iter "mo:base/Iter";
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
  type Entry = Types.MessageDbEntry;
  type ChatStatus = Types.ChatStatus;

  public func emptyDB() : MessageDB = Map.new();

  public func sendMessage(db : MessageDB, self : Principal, other : Principal, content : Text) : () {
    let key = keyFromPrincipals(self, other);
    let (msgs, statusSelf, statusOther) = getMsgs(db, self, other, key);
    let sender = self < other;

    let msg : Message = {
      sender;
      content;
      time = Time.now();
    };

    Buffer.add(msgs, msg);

    let status : ChatStatus = { unread = statusOther.unread + 1 };
    let entry : Entry = {
      messages = msgs;
      status1 = if (self < other) statusSelf else status;
      status2 = if (self < other) status else statusSelf;
    };
    Map.set(db, khash, key, entry);

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

  public func getMsgs(db : MessageDB, self : Principal, other : Principal, key : Key) : (Messages, ChatStatus, ChatStatus) {
    switch (Map.get<Key, Entry>(db, khash, key), (self < other)) {
      case (?data, true) { (data.messages, data.status1, data.status2) };
      case (?data, false) { (data.messages, data.status2, data.status1) };
      case (null, _) {
        // instert a new one if none is found
        let buf = Buffer.init<Message>();
        let status : ChatStatus = { unread = 0 };
        let entry : Entry = {
          messages = buf;
          status1 = status;
          status2 = status;
        };
        Map.set(db, khash, key, entry);
        (buf, status, status);
      };
    };
  };

  public type Unread = {
    from : Principal;
    unread : Nat;
    latest : Text;
  };
  public func getPending(db : MessageDB, self : Principal) : [Unread] {
    let out = Buffer.init<Unread>();
    for ((p1, p2) in Map.keys(db)) {
      if (p1 == self or p2 == self) {
        let key = keyFromPrincipals(p1, p2);
        let (msgs, statusSelf, _) = getMsgs(db, p1, p2, key);
        if (statusSelf.unread > 0) {
          Buffer.add<Unread>(
            out,
            {
              from = if (p1 == self) p2 else p1;
              unread = statusSelf.unread;
              // implicit assert of msgs.size >= 1 because unread is > 0. Otherwise the next line would trap
              latest = Buffer.get(msgs, Buffer.size(msgs) - 1 : Nat).content;
            },
          );
        };
      };
    };
    return Buffer.toArray(out);
  };

  public func getPendingWithUsers(db : MessageDB, self : Principal, users : Iter.Iter<Principal>) : [Unread] {
    let out = Buffer.init<Unread>();
    for (other in users) {
      let key = keyFromPrincipals(self, other);
      let (msgs, statusSelf, _) = getMsgs(db, self, other, key);
      if (statusSelf.unread > 0) {
        Buffer.add<Unread>(
          out,
          {
            from = other;
            unread = statusSelf.unread;
            // implicit assert of msgs.size >= 1 because unread is > 0. Otherwise the next line would trap
            latest = Buffer.get(msgs, Buffer.size(msgs) - 1 : Nat).content;
          },
        );
      };
    };
    return Buffer.toArray(out);
  };

  public func getMessages(db : MessageDB, self : Principal, other : Principal, markRead : Bool) : {
    messages : [Message];
    status : ChatStatus;
  } {
    let key = keyFromPrincipals(self, other);
    let (msgs, statusSelf, statusOther) = getMsgs(db, self, other, key);

    if (markRead and statusSelf.unread > 0) {
      let status : ChatStatus = { unread = 0 };
      let entry : Entry = {
        messages = msgs;
        status1 = if (self < other) status else statusOther;
        status2 = if (self < other) statusOther else status;
      };
      Map.set(db, khash, key, entry);
    };

    if (self < other) {
      return { messages = Buffer.toArray(msgs); status = statusSelf };
    };
    // invert sender before returning
    return {
      messages = Array.map<Message, Message>(Buffer.toArray(msgs), func(m) = { sender = not m.sender; content = m.content; time = m.time });
      status = statusSelf;
    };
  };

};
