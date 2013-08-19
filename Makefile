all: compile

compile:
	@rebar compile

clean:
	@rebar clean

deps:
	@rebar get-deps

generate:
	@rebar generate

run:
	@erl -pa apps/muz/ebin deps/*/ebin -s muz

.PHONY: deps
