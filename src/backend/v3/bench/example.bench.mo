import Bench "mo:bench";

import Nat "mo:base/Nat";
import Iter "mo:base/Iter";
import Buffer "mo:base/Buffer";
import Array "mo:base/Array";

module {
  public func init() : Bench.Bench {
    let bench = Bench.Bench();

    // benchmark code...
    bench.name("Array vs Buffer");
    bench.description("Add items one-by-one");

    bench.rows(["Array", "Buffer"]);
    bench.cols(["5", "8", "9", "10", "100"]);

    bench.runner(
      func(row, col) {
        let ?n = Nat.fromText(col) else return;

        // Array
        if (row == "Array") {
          var vec : [Nat] = [];
          for (i in Iter.range(1, n)) {
            vec := Array.append(vec, [i]);
          };
        };

        // Buffer
        if (row == "Buffer") {
          let buf = Buffer.Buffer<Nat>(0);
          for (i in Iter.range(1, n)) {
            buf.add(i);
          };
        };
      }
    );

    bench;
  };
};
