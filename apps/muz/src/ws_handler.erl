-module(ws_handler).
-behaviour(cowboy_websocket_handler).

-export([init/3]).
-export([websocket_init/3, websocket_handle/3, websocket_info/3,
         websocket_terminate/3]).

-include("muz.hrl").

init({ssl, http}, Req, Opts) ->
    ?INFO("Init"),
    {upgrade, protocol, cowboy_websocket, Req, Opts}.

websocket_init(_TransportName, Req, _Opts) ->
    ?INFO("Websocket init"),
    {ok, Req, undefined_state, hibernate}.

websocket_handle({text, Msg}, Req, State) ->
    case jsx:decode(Msg) of
        [{_, <<"start">>}] ->
            Email = muz_lib:get_option(email),
            Passwd = muz_lib:get_option(password),
            {ok, Pid} = mail_client:open_retrieve_session(
                        "ipv6.dp.ua", 993, Email, Passwd, [ssl, imap]),
            List = muz_mail_handler:mailbox_list(Pid),
            H = {binary:list_to_bin("email"), binary:list_to_bin(Email)},
            Answer = jsx:encode([H | List]);
        [{_, <<"inbox">>}] ->
            [Pid] = State,
            {ok, {_Mailbox, Mails}} = 
                mail_client:imap_select_mailbox(Pid, "INBOX", 2),
            Numbers = muz_mail_handler:get_mail_number(Mails),
            First = lists:last(Numbers),
            {ok, [{First, Raw}]} = 
                mail_client:imap_retrieve_message(Pid, First),
            Answer = muz_mail_handler:raw_message_to_mail(Raw, Msg)
    end, 
    {reply, {text, Answer}, Req, [Pid], hibernate};
websocket_handle(Data, Req, State) ->
    ?INFO("Handle: ~p", [Data]),
    {ok, Req, State}.

websocket_info({timeout, _Ref, Msg}, Req, State) ->
    ?INFO("Websocket timeout"),
    {reply, {text, Msg}, Req, State};
websocket_info(_Info, Req, State) ->
    ?INFO("Websocket info"),
    {ok, Req, State, hibernate}.

websocket_terminate(_Reason, _Req, _State) ->
    ok.
