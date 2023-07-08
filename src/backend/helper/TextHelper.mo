import Text "mo:base/Text";
import Prim "mo:⛔";

module {
  /// Convert all chars in a string to lower case
  // TODO: hopefully this will be part of the base library soon...
  public func toLower(text : Text) : Text {
    Text.map(text, Prim.charToLower);
  };
};
