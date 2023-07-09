.PHONY: check test examples
check:
	find src -type f -name '*.mo' -print0 | xargs -0 $(shell vessel bin)/moc $(shell vessel sources 2>/dev/null) --check
test:
	find test -type f -name '*.test.mo' -print0 | xargs -0 $(shell vessel bin)/moc $(shell vessel sources 2>/dev/null) -r
examples:
	find examples -type f -name '*.test.mo' -print0 | xargs -0 $(shell vessel bin)/moc --package probe src $(shell vessel sources 2>/dev/null) -r
