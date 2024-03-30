import { chapter; section; test; fail } "Test";
import Fixtures "Fixtures";
import Types "../Types";
import User "../User";

let users = Types.emptyUserDB();
let gen = Fixtures.Generator();

assert User.getPrincipal(users, "nonexistent") == null;

test "create User";
let fooId = gen.principal(0);

let #ok(_userA) = User.add(users, "foo", "about", "foo@bar", fooId) else {
  assert false;
  fail();
};

assert User.getPrincipal(users, "foo") == ?fooId;
