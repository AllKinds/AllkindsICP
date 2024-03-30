import { chapter; section; test; fail } "Test";
import Fixtures "Fixtures";
import Types "../Types";
import Debug "mo:base/Debug";

let gen = Fixtures.Generator();

chapter "Types V4";

section "Migrations";

test "from v3";

let dbv3 = gen.testDBv3();
let db = Types.migrateV3(dbv3);

Debug.print(debug_show (db));
