import Probe "mo:probe";
import { run; describe; test } "mo:probe";
import { debugPrint } = "mo:⛔";

let result = await* run([
    describe(
        "math",
        [
            test(
                "1 is equal to 2?",
                func(t : Probe.T) : async* () {
                    // Not executed, because failNow() above.
                    if (1 != 2) t.error("1 != 2");
                },
            ),
        ],
    )
]);
debugPrint(result);
