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
    Object = jsx:decode(Body),
    {Answ, RetCode} = login(Object),
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
    Password = binary:bin_to_list(Pass),
    io:format("~p ~p~n", [Email, Password]),
    try
        {ok, Pid} = mail_client:open_retrieve_session("ipv6.dp.ua", 993,
                Email, Password, [ssl, imap]),
        {ok, List} = mail_client:imap_list_mailbox(Pid),
        case get_mailbox_state(List) of
            {"UNSEEN", Val} ->
                Answ = "{\"ok\": \"" ++ Val ++ "\"}",
                {binary:list_to_bin(Answ), 200};
            {error, Reason} ->
                Error = "{\"error\": \"" ++ Reason ++ "\"}",
                {binary:list_to_bin(Error), 503}
        end
    catch
        _:_ ->
            {<<"{\"error\": \"invalid login/password\"}">>, 404}
    end.

-spec get_mailbox_state(list()) -> {State :: string(), Value :: string()}.
get_mailbox_state([]) ->
    {error, inbox_not_fined};
get_mailbox_state([H|T]) ->
    case H of
        {"INBOX", _, List} ->
            {State, Val} = lists:keyfind("UNSEEN", 1, List),
            {State, Val};
        _ ->
            get_mailbox_state(T)
    end.
