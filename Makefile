all: compile

compile:
	@rebar compile

clean:
	@rebar clean

deps:
	@rebar get-deps

test:
	@rebar xref skip_deps=true

release:
	@rebar generate

run:
	@erl -pa apps/muz/ebin deps/*/ebin -config rel/files/sys.config -s muz

.PHONY: deps
