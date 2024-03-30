import Text "mo:base/Text";
import Map "mo:map/Map";
import Iter "mo:base/Iter";
import IC "mo:base/ExperimentalInternetComputer";

module {
  type Iter<T> = Iter.Iter<T>;
  type Map<K, V> = Map.Map<K, V>;
  let { thash } = Map;

  public type PerformanceDB = Map<Text, Nat64>;

  public func emptyDB() : PerformanceDB = Map.new<Text, Nat64>();

  public func track(perf : PerformanceDB, team : Text) {
    ignore Map.update<Text, Nat64>(
      perf,
      thash,
      team,
      func(k, x) = switch (x) {
        case (?v) ?(v + IC.performanceCounter(1));
        case (null) ?IC.performanceCounter(1);
      },
    );
  };

  public func dump(perf : PerformanceDB) : Iter<(Text, Nat64)> {
    Map.entries(perf);
  };
};
