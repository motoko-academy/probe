import { run; describe; test } "../src";
import Probe "../src";

import { debugPrint; error; errorMessage } = "mo:⛔";

do {
  let r = await* run([
    describe(
      "methods",
      [
        test(
          "test",
          func(t : Probe.T) : async* () {
            t.error("oops");
          },
        ),
        test(
          "failNow",
          func(t : Probe.T) : async* () {
            await* t.failNow();
          },
        ),
        test(
          "error",
          func(t : Probe.T) : async* () {
            // Not executed, because failNow() above.
            if (1 != 2) t.error("1 != 2");
          },
        ),
      ],
    )
  ]);

  debugPrint(r);
  assert (r == "{\"tests\": [{\"type\": \"describe\", \"tests\": [{\"type\": \"test\", \"name\": \"test\", \"passed\": false, \"errors\": [\"oops\"]}, {\"type\": \"test\", \"name\": \"failNow\", \"passed\": false, \"errors\": []}]}]}");
};

do {
  let r = await* run([
    describe(
      "methods",
      [
        test(
          "error",
          func(t : Probe.T) : async* () {
            if (1 != 2) t.error("1 != 2");
          },
        ),
        test(
          "error",
          func(t : Probe.T) : async* () {
            if (1 != 2) await* t.fatal("1 != 2");
            t.error("not executed");
          },
        ),
      ],
    )
  ]);

  debugPrint(r);
  assert (r == "{\"tests\": [{\"type\": \"describe\", \"tests\": [{\"type\": \"test\", \"name\": \"error\", \"passed\": false, \"errors\": [\"1 != 2\"]}, {\"type\": \"test\", \"name\": \"error\", \"passed\": false, \"errors\": [\"1 != 2\"]}]}]}");
};

do {
  let r = await* run([
    describe(
      "methods",
      [
        test(
          "custom error",
          func(t : Probe.T) : async* () {
            throw error("you can throw errors");
          },
        ),
      ],
    )
  ]);

  debugPrint(r);
  assert (r == "{\"tests\": [{\"type\": \"describe\", \"tests\": [{\"type\": \"test\", \"name\": \"custom error\", \"passed\": false, \"errors\": [\"you can throw errors\"]}]}]}");
};
