import Text "mo:base/Text";
import Prim "mo:⛔";

module {
  /// Convert all chars in a string to lower case
  // TODO: hopefully this will be part of the base library soon...
  public func toLower(text : Text) : Text {
    Text.map(text, Prim.charToLower);
  };
  public func charToLower(c : Char) : Text {
    Text.fromChar(Prim.charToLower(c));
  };

  // private function from base library
  public func extract(t : Text, i : Nat, j : Nat) : Text {
    let size = t.size();
    if (i == 0 and j == size) return t;
    assert (j <= size);
    let cs = t.chars();
    var r = "";
    var n = i;
    while (n > 0) {
      ignore cs.next();
      n -= 1;
    };
    n := j;
    while (n > 0) {
      switch (cs.next()) {
        case null { assert false };
        case (?c) { r #= Prim.charToText(c) };
      };
      n -= 1;
    };
    return r;
  };
};
