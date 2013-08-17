-module(webserver).

-export([start/0, stop/0, update_routes/0]).

start() ->
    lager:start(),
    ok = application:start(crypto),
    ok = application:start(ranch),
    ok = application:start(cowboy),
    ok = application:start(webserver),
    ok = sync:go().

update_routes() ->
    Routes = webserver_app:dispatch_rules(),
    cowboy:set_env(http, dispatch, Routes).

stop() ->
    sync:stop(),
    application:stop(webserver),
    application:stop(cowboy),
    application:stop(ranch),
    application:stop(crypto),
    lager:stop(),
    ok.
