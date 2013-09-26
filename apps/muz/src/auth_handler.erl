-module(auth_handler).

-export([init/3,
         content_types_accepted/2,
         handle_to_all/2,
         allowed_methods/2]).

-include("muz.hrl").

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
    Object = jsx:decode(Body),
    {Answ, RetCode, Email, Passwd} = login(Object),
    application:set_env(muz, email, Email),
    application:set_env(muz, password, Passwd),
    Req2 = cowboy_req:set_resp_body(Answ, Req1),
    Req3 = cowboy_req:set_resp_header(
        <<"content-type">>, <<"application/json">>, Req2),
    Reply = cowboy_req:reply(RetCode, Req3),
    {halt, Reply, State}.

%% Internal functions

-spec login(Object :: list()) -> {AnswString :: binary(), Code :: string()}.
login([H|[T]]) ->
    {<<"email">>, Em} = H,
    {<<"passwd">>, Pass} = T,
    Email = binary:bin_to_list(Em),
    Psw = binary:bin_to_list(Pass),
    try
        {ok, _Pid} = mail_client:open_retrieve_session("ipv6.dp.ua", 993,
                    Email, Psw, [ssl, imap]),
        {<<"{\"ok\": \"Successful login\"}">>, 200, Email, Psw}
    catch
        _:_ ->
            {<<"{\"error\": \"invalid login/password\"}">>, 404, Email, Psw}
    end.
