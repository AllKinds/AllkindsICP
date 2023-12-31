import { chapter; section; test; fail } "Test";
import User "../User";
import Fixtures "Fixtures";

let users = User.emptyDB();
let gen = Fixtures.Generator();

assert User.getPrincipal(users, "nonexistent") == null;

test "create User";
let fooId = gen.principal(0);

let #ok(userA) = User.add(users, "foo", "foo@bar", fooId) else {
  assert false;
  fail();
};

assert User.getPrincipal(users, "foo") == ?fooId;
