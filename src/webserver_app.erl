-module(webserver_app).
-behaviour(application).

-export([start/2, stop/1]).
-export([dispatch_rules/0]).

%% Api

start(_Type, _Args) ->
    Dispatch = dispatch_rules(),
    {ok, _} = cowboy:start_http(http, 100, 
        [{port, 9999}],
        [{env, [{dispatch, Dispatch}]}]
    ),
    lager:log(info, self(), "Starting mail-muzzle HTTP web server", []),
    webserver_sup:start_link().

stop(_State) ->
    ok.

%% Application functions

dispatch_rules() ->
    Static = fun(Type) ->
        {lists:append(["/", Type, "/[...]"]), cowboy_static, [
            {directory, {priv_dir, webserver, [list_to_binary(Type)]}},
            {mimetypes, {fun mimetypes:path_to_mimes/2, default}}]    
        }
    end,
    cowboy_router:compile([
        {'_',[
            Static("css"),
            Static("img"),
            Static("js"),
            {"/", cowboy_static, [
                {directory, {priv_dir, webserver, []}},
                {file, "index.html"},
                {mimetypes, {fun mimetypes:path_to_mimes/2, default}}
            ]}
        ]}
    ]).

