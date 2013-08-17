all: compile

compile:
	rebar compile

clean:
	rebar clean

deps:
	rebar get-deps

run:
	erl -pa ebin deps/*/ebin -s webserver

.PHONY: all compile deps run clean
