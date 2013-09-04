-module(muz_app).
-behaviour(application).

-export([start/2, stop/1]).

%% Api

start(_Type, _Args) ->
    Dispatch = dispatch_rules(),
    {ok, Port} = application:get_env(muz, port),
    {ok, _} = cowboy:start_https(https, 100, [
            {port, Port},
            {certfile, code:priv_dir(muz) ++ "/ssl/server.crt"},
            {keyfile, code:priv_dir(muz) ++ "/ssl/server.key"}
        ],
        [{env, [{dispatch, Dispatch}]}]
    ),
    lager:log(info, self(), 
    "Starting mail-muzzle HTTPS web server on https://localhost:9999", []),
    muz_sup:start_link().

stop(_State) ->
    ok.

%% Application functions

dispatch_rules() ->
    Static = fun(Type) ->
        {lists:append(["/", Type, "/[...]"]), cowboy_static, [
            {directory, {priv_dir, muz, [list_to_binary(Type)]}},
            {mimetypes, {fun mimetypes:path_to_mimes/2, default}}]    
        }
    end,
    cowboy_router:compile([
        {'_',[
            Static("css"),
            Static("js"),
            Static("img"),
            {"/", cowboy_static, [
                {directory, {priv_dir, muz, []}},
                {file, "index.html"},
                {mimetypes, {fun mimetypes:path_to_mimes/2, default}}
            ]}
        ]}
    ]).

