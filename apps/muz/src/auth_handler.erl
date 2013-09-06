-module(auth_handler).

-export([init/3,
         content_types_accepted/2,
         handle_to_all/2,
         allowed_methods/2]).

init(_Transport, _Req, []) ->
    {upgrade, protocol, cowboy_rest}.

allowed_methods(Req, State) ->
    {[<<"GET">>, <<"POST">>], Req, State}.

content_types_accepted(Req, State) ->
    {[
        {{<<"application">>, <<"json">>, []}, handle_to_all}
    ], Req, State}.

handle_to_all(Req, State) ->
    {ok, Body, Req1} = cowboy_req:body(Req),
    {struct, _Object} = mochijson2:decode(Body),
    Json_answ = <<"{\"error\": \"invalid login/password\"}">>,
    Req2 = cowboy_req:set_resp_body(Json_answ, Req1),
    Req3 = cowboy_req:set_resp_header(
        <<"content-type">>, <<"application/json">>, Req2),
    Reply = cowboy_req:reply(404, Req3),
    {halt, Reply, State}.
