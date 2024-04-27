import { chapter; section; test; fail } "Test";
import Fixtures "Fixtures";
import Types "../Types";
import Debug "mo:base/Debug";

let gen = Fixtures.Generator();

chapter "Types V4";

section "Migrations";

test "from v3";

let dbv1 = gen.testDBv3();
let db = Types.migrateV1(dbv1);
