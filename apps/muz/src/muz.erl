-module(muz).

%% API
-export([start/0]).

start() ->
    ok = application:start(lager),
    ok = application:start(crypto),
    ok = application:start(ranch),
    ok = application:start(cowboy),
    ok = application:start(muz).
