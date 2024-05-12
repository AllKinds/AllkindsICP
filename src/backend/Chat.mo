import Time "mo:base/Time";
import Hash "mo:base/Hash";
import Principal "mo:base/Principal";
import Array "mo:base/Array";
import Iter "mo:base/Iter";
import Nat32 "mo:base/Nat32";
import Map "mo:map/Map";

import Buffer "mo:StableBuffer/StableBuffer";
import Types "types/Types";

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

  public func sendMessage(db : MessageDB, self : Principal, other : Principal, content : Text) {
    let key = keyFromPrincipals(self, other);
    let msgs = getMsgs(db, self, other, key);
    let senderIs1 = isSelf1(self, other);

    let msg : Message = {
      sender = senderIs1;
      content;
      time = Time.now();
    };

    Buffer.add(msgs.messages, msg);

    let status : ChatStatus = { unread = msgs.other.unread + 1 };
    let entry : Entry = {
      messages = msgs.messages;
      status1 = if (senderIs1) msgs.self else status;
      status2 = if (senderIs1) status else msgs.self;
    };
    Map.set(db, khash, key, entry);
  };

  func keyFromPrincipals(a : Principal, b : Principal) : Key {
    if (a > b) return (b, a);
    return (a, b);
  };

  func keyHash(key : Key) : Hash.Hash {
    let (a, b) = key;
    return Nat32.addWrap(Principal.hash(a), Principal.hash(b));
  };

  func keyEqual(a : Key, b : Key) : Bool {
    a == b;
  };

  func isSelf1(self : Principal, other : Principal) : Bool = self < other;

  let khash : Map.HashUtils<Key> = (keyHash, keyEqual);

  public func getMsgs(db : MessageDB, self : Principal, other : Principal, key : Key) : {
    messages : Messages;
    self : ChatStatus;
    other : ChatStatus;
  } {
    switch (Map.get<Key, Entry>(db, khash, key), isSelf1(self, other)) {
      case (?data, true) {
        { messages = data.messages; self = data.status1; other = data.status2 };
      };
      case (?data, false) {
        { messages = data.messages; self = data.status2; other = data.status1 };
      };
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
        { messages = buf; self = status; other = status };
      };
    };
  };

  public type Unread = {
    from : Principal;
    unread : Nat;
    latest : Message;
  };

  public func getPending(db : MessageDB, self : Principal, showNonPending : Bool) : [Unread] {
    let out = Buffer.init<Unread>();
    for ((p1, p2) in Map.keys(db)) {
      if (p1 == self or p2 == self) {
        let other = if (p1 == self) p2 else p1;
        let key = keyFromPrincipals(self, other);
        let msgs = getMsgs(db, self, other, key);
        if ((showNonPending and Buffer.size(msgs.messages) > 0) or msgs.self.unread > 0) {
          let latest = Buffer.get(msgs.messages, Buffer.size(msgs.messages) - 1 : Nat);
          Buffer.add<Unread>(
            out,
            {
              from = other;
              unread = msgs.self.unread;
              // implicit assert of msgs.size >= 1 because unread is > 0. Otherwise the next line would trap
              latest = fixSender(latest, isSelf1(self, other));
            },
          );
        };
      };
    };
    return Buffer.toArray(out);
  };

  /// Get number of pending messages and the content of the lates message
  /// showNonPending: if false, only return entries where at least one message is pending
  public func getPendingWithUsers(db : MessageDB, self : Principal, users : Iter.Iter<Principal>, showNonPending : Bool) : [Unread] {
    let out = Buffer.init<Unread>();
    for (other in users) {
      let key = keyFromPrincipals(self, other);
      let msgs = getMsgs(db, self, other, key);
      if ((showNonPending and Buffer.size(msgs.messages) > 0) or msgs.self.unread > 0) {
        let latest = Buffer.get(msgs.messages, Buffer.size(msgs.messages) - 1 : Nat);
        Buffer.add<Unread>(
          out,
          {
            from = other;
            unread = msgs.self.unread;
            latest = fixSender(latest, isSelf1(self, other));
          },
        );
      };
    };
    return Buffer.toArray(out);
  };

  public func getMessages(db : MessageDB, self : Principal, other : Principal) : {
    messages : [Message];
    status : ChatStatus;
  } {
    let key = keyFromPrincipals(self, other);
    let msgs = getMsgs(db, self, other, key);

    if (isSelf1(self, other)) {
      return { messages = Buffer.toArray(msgs.messages); status = msgs.self };
    };
    // invert sender before returning
    return {
      messages = Array.map<Message, Message>(Buffer.toArray(msgs.messages), func(m) = fixSender(m, false));
      status = msgs.self;
    };
  };

  func fixSender(msg : Message, selfIs1 : Bool) : Message {
    if (selfIs1) return msg;
    return {
      time = msg.time;
      sender = not msg.sender;
      content = msg.content;
    };
  };

  public func markRead(db : MessageDB, self : Principal, other : Principal) : Nat {
    let key = keyFromPrincipals(self, other);
    let msgs = getMsgs(db, self, other, key);
    if (msgs.self.unread > 0) {
      let statusReset : ChatStatus = { unread = 0 };
      let entry : Entry = {
        messages = msgs.messages;
        status1 = if (isSelf1(self, other)) statusReset else msgs.other;
        status2 = if (isSelf1(self, other)) msgs.other else statusReset;
      };
      Map.set(db, khash, key, entry);
    };
    return msgs.self.unread;
  };

};
