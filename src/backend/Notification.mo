import Types "Types";
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

  public func getAll(users : UserDB, teams : Types.TeamDB, chat : Types.MessageDB, principal : Principal) : [Notification] {
    let buffer = Buffer.Buffer<Notification>(8);
    buffer.append(Buffer.fromArray(getChat(teams, users, chat, principal)));
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

  func toToNotification(teamsDB : Types.TeamDB, users : UserDB, principal : Principal) : (msg : Chat.Unread) -> Notification {
    func(msg : Chat.Unread) : Notification {
      let teams = Array.map<Types.TeamUserInfo, Text>(
        getTeams(teamsDB, principal, msg.from),
        func(t) : Text = t.info.name,
      );

      return toNotification(users, principal, teams, msg);
    };
  };
  func toToNotificationInTeam(team : Team, users : UserDB, principal : Principal) : (msg : Chat.Unread) -> Notification {
    let teams = [team.info.name];
    return func(msg : Chat.Unread) : Notification {
      toNotification(users, principal, teams, msg);
    };
  };

  func toNotification(users : UserDB, principal : Principal, teams : [Text], msg : Chat.Unread) : Notification {
    return {
      event = #chat({
        unread = msg.unread;
        user = getUsername(users, principal);
        latest = msg.latest;
      });
      team = teams;
    };
  };

  public func getChat(teamsDB : Types.TeamDB, users : UserDB, chat : Types.MessageDB, principal : Principal) : [Notification] {
    let msgs = Chat.getPending(chat, principal);
    Array.map(msgs, toToNotification(teamsDB, users, principal));
  };

  public func getChatInTeam(team : Team, users : UserDB, chat : Types.MessageDB, principal : Principal, friends : Iter<Principal>) : [Notification] {
    let msgs = Chat.getPendingWithUsers(chat, principal, friends);
    let a = Array.map(msgs, toToNotificationInTeam(team, users, principal));
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
