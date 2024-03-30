module {
  public func mapFirst<A, B, C>((first, second) : (A, B), f : A -> C) : (C, B) {
    (f(first), second);
  };

  public func mapSecond<A, B, C>((first, second) : (A, B), f : B -> C) : (A, C) {
    (first, f(second));
  };
};
