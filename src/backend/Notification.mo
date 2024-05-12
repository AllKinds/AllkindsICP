import Types "types/Types";
import Buffer "mo:base/Buffer";
import Array "mo:base/Array";
import Iter "mo:base/Iter";
import Map "mo:map/Map";
import Friend "Friend";
import Chat "Chat";
import User "User";
import Team "Team";

module {

  type Notification = Types.Notification;
  type Team = Types.Team;
  type UserDB = Types.UserDB;
  type Buffer<T> = Buffer.Buffer<T>;
  type Iter<T> = Iter.Iter<T>;

  public func getAll(users : UserDB, teams : Types.TeamDB, chat : Types.MessageDB, principal : Principal, showNonPending : Bool) : [Notification] {
    let buffer = Buffer.Buffer<Notification>(8);
    buffer.append(Buffer.fromArray(getChat(teams, users, chat, principal, showNonPending)));
    for ((key, team) in Map.entries(teams)) {
      buffer.append(Buffer.fromArray(getTeam(key, team, users, chat, principal)));
    };
    return Buffer.toArray(buffer);
  };

  func getUsername(users : UserDB, principal : Principal) : Text {
    let ?user = User.get(users, principal) else return "N/A";
    user.username;
  };

  func getTeams(teamsDB : Types.TeamDB, self : Principal, other : Principal) : [Types.TeamUserInfo] {
    let teams = Team.listCommon(teamsDB, self, other);
    return teams;
  };

  func toToNotification(teamsDB : Types.TeamDB, users : UserDB, self : Principal, hideContent : Bool) : (msg : Chat.Unread) -> Notification {
    func(msg : Chat.Unread) : Notification {
      let teams = Array.map<Types.TeamUserInfo, Text>(
        getTeams(teamsDB, self, msg.from),
        func(t) : Text = t.info.name,
      );

      return toNotification(users, teams, msg, hideContent);
    };
  };

  func toToNotificationInTeam(team : Team, users : UserDB, hideContent : Bool) : (msg : Chat.Unread) -> Notification {
    let teams = [team.info.name];
    return func(msg : Chat.Unread) : Notification {
      toNotification(users, teams, msg, hideContent);
    };
  };

  func toNotification(users : UserDB, teams : [Text], msg : Chat.Unread, hideContent : Bool) : Notification {
    if (hideContent) {
      // content filtered to only include data which is safe to show to admins or third party notification system
      return {
        event = #chat({
          unread = msg.unread;
          user = "<hidden>";
          latest = {
            content = "<hidden>";
            time = msg.latest.time;
            sender = msg.latest.sender;
          };
        });
        team = teams;
      };
    };
    return {
      event = #chat({
        unread = msg.unread;
        user = getUsername(users, msg.from);
        latest = msg.latest;
      });
      team = teams;
    };
  };

  public func getChat(teamsDB : Types.TeamDB, users : UserDB, chat : Types.MessageDB, principal : Principal, showNonPending : Bool) : [Notification] {
    let msgs = Chat.getPending(chat, principal, showNonPending);
    let hideContent = not showNonPending;
    Array.map(msgs, toToNotification(teamsDB, users, principal, hideContent));
  };

  public func getChatInTeam(team : Team, users : UserDB, chat : Types.MessageDB, principal : Principal, friends : Iter<Principal>) : [Notification] {
    let msgs = Chat.getPendingWithUsers(chat, principal, friends, true);
    let a = Array.map(msgs, toToNotificationInTeam(team, users, false));
    return a;
  };

  public func getTeam(teamKey : Text, team : Types.Team, users : UserDB, chat : Types.MessageDB, principal : Principal) : [Notification] {
    let buffer = Buffer.Buffer<Notification>(8);

    buffer.append(Buffer.fromArray(getChatInTeam(team, users, chat, principal, Friend.getConnected(team.friends, principal))));

    let userFriends = Friend.get(team.friends, principal);
    var reqCount = 0;
    for ((p, status) in userFriends) {
      if (status == #requestReceived) {
        reqCount += 1;
      };
    };
    let requests = {
      team = [teamKey];
      event = #friendRequests(reqCount);

    };
    if (reqCount > 0) {
      return [requests];
    };

    return [];
  };

};
