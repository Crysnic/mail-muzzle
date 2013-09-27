PROJECT = muz

ERL = erl
REBAR = rebar
LIBS = ERL_LIBS=apps:deps
DIALYZER = dialyzer

.PHONY: deps

compile:
	@$(LIBS) $(REBAR) compile

deps:
	@$(REBAR) get-deps

test: compile
	@$(LIBS) $(REBAR) xref eunit skip_deps=true

run:
	@$(LIBS) $(REBAR) compile skip_deps=true
	@$(LIBS) $(ERL) -config rel/files/sys.config \
		-args_files rel/files/vm.args \
		-s muz +pc unicode

build-plt:
	@$(LIBS) $(DIALYZER) --build_plt --output_plt $(PROJECT).plt \
		--apps erts kernel stdlib crypto

dialyze:
	@$(LIBS) $(DIALYZER) --src apps/$(PROJECT)/src -r apps/$(PROJECT)/src \
		-I apps/$(PROJECT)/include --plt $(PROJECT).plt \
		-Werror_handling -Wrace_conditions -Wunmatched_returns --no_native

release: test
	@$(REBAR) generate
