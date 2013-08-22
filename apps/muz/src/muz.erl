-module(muz).

-export([start/0, stop/0]).

start() ->
    ok = application:start(lager),
    ok = application:start(crypto),
    ok = application:start(ranch),
    ok = application:start(cowboy),
    ok = application:start(muz),
    ok = sync:go().

stop() ->
    sync:stop(),
    application:stop(muz),
    application:stop(cowboy),
    application:stop(ranch),
    application:stop(crypto),
    application:stop(lager),
    ok.
