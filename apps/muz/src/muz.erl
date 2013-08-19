-module(muz).

-export([start/0, stop/0, update_routes/0]).

start() ->
    ok = application:start(lager),
    ok = application:start(crypto),
    ok = application:start(ranch),
    ok = application:start(cowboy),
    ok = application:start(muz),
    ok = sync:go().

update_routes() ->
    Routes = muz_webserver_app:dispatch_rules(),
    cowboy:set_env(http, dispatch, Routes).

stop() ->
    sync:stop(),
    application:stop(muz),
    application:stop(cowboy),
    application:stop(ranch),
    application:stop(crypto),
    application:stop(lager),
    ok.
