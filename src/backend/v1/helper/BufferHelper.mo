import Buffer "mo:StableBuffer/StableBuffer";
import Iter "mo:base/Iter";

module {
  type Buffer<T> = Buffer.StableBuffer<T>;
  type Iter<T> = Iter.Iter<T>;

  public func valsReverse<T>(buffer : Buffer<T>) : Iter<T> {
    var i = Buffer.size(buffer);
    func next() : ?T {
      if (i > 0 and i <= Buffer.size(buffer)) {
        i -= 1;
        return ?Buffer.get(buffer, i);
      } else {
        return null;
      };
    };
    { next };
  };
};
