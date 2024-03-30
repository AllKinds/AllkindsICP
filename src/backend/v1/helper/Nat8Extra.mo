module {

  public func compareDesc(a : Nat8, b : Nat8) : { #less; #equal; #greater } {
    if (a < b) return #greater;
    if (a > b) return #less;
    return #equal;
  };
};
