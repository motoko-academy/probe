package probe

import (
	"encoding/json"
	"os/exec"
	"strings"
	"testing"

	"github.com/santhosh-tekuri/jsonschema/v5"
)

func TestSchema(t *testing.T) {
	c := jsonschema.NewCompiler()
	c.Draft = jsonschema.Draft2020
	s, err := c.Compile("schema.json")
	if err != nil {
		t.Fatal(err)
	}
	for _, test := range []string{
		`{"tests": []}`,
		`{"tests": [{"type": "test", "name": "test1", "passed": true}]}`,
		`{"tests": [{"type": "describe", "tests": []}]}`,
	} {
		var v any
		if err := json.Unmarshal([]byte(test), &v); err != nil {
			t.Fatal(err)
		}
		if err := s.Validate(v); err != nil {
			t.Fatal(test, err)
		}
	}
}

func TestMotokoTests(t *testing.T) {
	c := jsonschema.NewCompiler()
	c.Draft = jsonschema.Draft2020
	s, err := c.Compile("schema.json")
	if err != nil {
		t.Fatal(err)
	}
	raw, err := exec.Command("make", "test").CombinedOutput()
	if err != nil {
		t.Fatal(err)
	}
	for _, test := range strings.Split(string(raw), "\n")[1:] {
		test := strings.TrimSpace(test)
		if len(test) == 0 {
			continue
		}

		var v any
		if err := json.Unmarshal([]byte(test), &v); err != nil {
			t.Fatal(test, err)
		}
		if err := s.Validate(v); err != nil {
			t.Fatal(test, err)
		}
	}
}
