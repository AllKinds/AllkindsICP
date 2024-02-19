import List "mo:base/List";
import TrieMap "mo:base/TrieMap";
import Principal "mo:base/Principal";
import Time "mo:base/Time";
import Array "mo:base/Array";
import Result "mo:base/Result";
import Configuration "Configuration";
import Char "mo:base/Char";
import Text "mo:base/Text";
import Map "mo:map/Map";
import Set "mo:map/Set";
import Int "mo:base/Int";
import Error "Error";
import Iter "mo:base/Iter";
import Debug "mo:base/Debug";
import Nat8 "mo:base/Nat8";
import TextHelper "helper/TextHelper";
import Option "mo:base/Option";
import TupleHelper "helper/TupleHelper";
import StableBuffer "mo:StableBuffer/StableBuffer";
import IC "mo:base/ExperimentalInternetComputer";

module {
  type Iter<T> = Iter.Iter<T>;
  type Map<K, V> = Map.Map<K, V>;
  let { thash; phash } = Map;

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
