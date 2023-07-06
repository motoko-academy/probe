# Probe

```Motoko
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
// {"tests": [{"type": "describe", "tests": [{"type": "test", "name": "1 is equal to 2?", "passed": false, "errors": ["1 != 2"]}]}]}
```

## JSON Response Format

```json
{
    "tests": [
        {
            "type": "describe",
            "tests": [
                {
                    "type": "test",
                    "name": "test001",
                    "passed": true
                },
                {
                    "type": "test",
                    "name": "test002",
                    "passed": false,
                    "errors": [
                        "error list"
                    ]
                }
            ]
        }
    ]
}
```

## Improvements

- Do not allow tests with duplicate names on the same depth.
