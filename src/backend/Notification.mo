import Types "Types";
import Buffer "mo:base/Buffer";
import Map "mo:map/Map";
import Team "Team";
import Friend "Friend";

module {

  type Notification = Types.Notification;
  type Team = Types.Team;

  public func getAll(teams : Types.TeamDB, principal : Principal) : [Notification] {
    let buffer = Buffer.Buffer<Notification>(8);
    for ((key, team) in Map.entries(teams)) {
      buffer.append(Buffer.fromArray(getTeam(key, team, principal)));
    };
    return Buffer.toArray(buffer);
  };

  public func getTeam(teamKey : Text, team : Types.Team, principal : Principal) : [Notification] {
    let userFriends = Friend.get(team.friends, principal);
    var reqCount = 0;
    for ((p, status) in userFriends) {
      if (status == #requestReceived) {
        reqCount += 1;
      };
    };
    let requests = {
      team = teamKey;
      event = #friendRequests(reqCount);

    };
    if (reqCount > 0) {
      return [requests];
    };

    return [];
  };

};
