import { map; foldLeft } = "mo:base/Array";
import Buffer "mo:base/Buffer";
import { errorMessage; error = panic } = "mo:⛔";
import Bool "mo:base/Bool";

module {
  public type T = {
    // Fatal is equivalent to Log followed by FailNow.
    fatal : (msg : Text) -> async* ();
    // Fail marks the function as having failed but continues execution.
    fail : () -> ();
    // Failed returns true if the function has failed.
    failed : () -> Bool;
    // FailNow marks the function as having failed and stops its execution.
    failNow : () -> async* ();

    // Log records the given message to the error log.
    log : (msg : Text) -> ();

    // Logs returns the test's accumulated logs.
    logs : () -> [Text];

    // Error is equivalent to Log followed by Fail.
    error : (msg : Text) -> ();

    // Skip is equivalent to Log followed by SkipNow.
    skip : (msg : Text) -> async* ();

    // SkipNow marks the test as having been skipped and stops its execution.
    skipNow : () -> async* ();

    // Skipped returns true if the test was skipped.
    skipped : () -> Bool;
  };

  private class Testing() : T = t {
    let _logs = Buffer.Buffer<Text>(0);
    var _failed : Bool = false;
    var _skipped : Bool = false;
    var _finished : Bool = false;

    public func fatal(msg : Text) : async* () {
      t.log(msg);
      await* t.failNow();
    };

    public func fail() {
      _failed := true;
    };

    public func failed() : Bool {
      _failed;
    };

    public func failNow() : async* () {
      t.fail();
      _finished := true;
      throw panic("failNow");
    };

    public func log(msg : Text) {
      _logs.add(msg);
    };

    public func logs() : [Text] {
      Buffer.toArray(_logs);
    };

    public func error(msg : Text) {
      t.log(msg);
      t.fail();
    };

    public func skip(msg : Text) : async* () {
      t.log(msg);
      await* t.skipNow();
    };

    public func skipNow() : async* () {
      _skipped := true;
      _finished := true;
      throw panic("skipNow");
    };

    public func skipped() : Bool {
      _skipped;
    };
  };

  public type Test = (t : T) -> async* ();

  private type Callback = () -> ();
  private let doNothing = func() {};

  public type NamedTest = {
    #Describe : (Text, [NamedTest]);
    #Test : (Text, Test);
  };

  public func describe(name : Text, tests : [NamedTest]) : NamedTest {
    #Describe(name, tests);
  };

  public func test(name : Text, test : (t : T) -> async* ()) : NamedTest {
    #Test(name, test);
  };

  public func run(ts : [NamedTest]) : async* Text {
    await* Suite().run(ts);
  };

  public class Suite() {
    var _before : Callback = doNothing;
    public func before(c : Callback) { _before := c };

    var _beforeEach : Callback = doNothing;
    public func beforeEach(c : Callback) { _beforeEach := c };

    var _after : Callback = doNothing;
    public func after(c : Callback) { _after := c };

    var _afterEach : Callback = doNothing;
    public func afterEach(c : Callback) { _afterEach := c };

    public func run(ts : [NamedTest]) : async* Text {
      _before();
      let r = await* _run(ts);
      _after();
      mJSON.show(#Object([("tests", r)]));
    };

    private func _run(ts : [NamedTest]) : async* mJSON.JSON {
      let b = Buffer.Buffer<mJSON.JSON>(ts.size());
      label l for (test in ts.vals()) {
        switch (test) {
          case (#Describe(name, ts)) {
            b.add(#Object([
              ("type", #String("describe")),
              ("tests", await* _run(ts))
            ]));
          };
          case (#Test(name, f)) {
            _beforeEach();
            let t = Testing();
            let tb = Buffer.Buffer<(Text, mJSON.JSON)>(4);
            tb.add(("type", #String("test")));
            tb.add(("name", #String(name)));
            try (await* f(t)) catch (e) {
              switch (errorMessage(e)) {
                case ("failNow" or "skipNow") {};
                case msg t.log(msg);
              };
              let logs = t.logs();
              tb.add(("passed", #Boolean(false)));
              tb.add(("errors", #Array(map<Text, mJSON.JSON>(logs, func(log : Text) { #String(log) }))));
              b.add(#Object(Buffer.toArray(tb)));
              if (t.failed()) break l;
              continue l;
            };

            let logs = t.logs();
            switch (logs.size()) {
              case 0 tb.add(("passed", #Boolean(true)));
              case _ {
                tb.add(("passed", #Boolean(false)));
                tb.add(("errors", #Array(map<Text, mJSON.JSON>(logs, func(log : Text) { #String(log) }))));
              };
            };
            b.add(#Object(Buffer.toArray(tb)));
            _afterEach();
          };
        };
      };
      #Array(Buffer.toArray(b));
    };
  };

  // mJSON is a simple JSON library.
  private module mJSON {
    public type JSON = {
      #String : Text;
      #Boolean : Bool;
      #Array : [JSON];
      #Object : [(Text, JSON)];
    };

    public func show(json : JSON) : Text = switch (json) {
      case (#String v) { "\"" # v # "\"" };
      case (#Boolean v) { if (v) "true" else "false" };
      case (#Array xs) {
        "[" # foldLeft(
          xs,
          "",
          func(t : Text, x : JSON) : Text {
            switch (t) {
              case ("") show(x);
              case (_) t # ", " # show(x);
            };
          },
        ) # "]";
      };
      case (#Object xs) {
        "{" # foldLeft(
          xs,
          "",
          func(t : Text, (k, v) : (Text, JSON)) : Text {
            switch (t) {
              case ("") "\"" # k # "\": " # show(v);
              case (t) t # ", \"" # k # "\": " # show(v);
            };
          },
        ) # "}";
      };
    };
  };
};
