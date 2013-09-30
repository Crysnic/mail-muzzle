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
        [{_, <<"start">>}, {_, Email}, {_, Passwd}] ->
            {ok, Pid} = mail_client:open_retrieve_session(
                        "ipv6.dp.ua",
                        993,
                        binary:bin_to_list(Email),
                        binary:bin_to_list(Passwd),
                        [ssl, imap]),
            List = muz_mail_handler:mailbox_list(Pid),
            Answer = jsx:encode(List);
        [{_, [{<<"index">>, Value}, {<<"mailbox">>, MBox}]}] ->
            [Pid] = State,
            mail_client:imap_select_mailbox(Pid, binary_to_list(MBox), 1),
            Letter = muz_mail_handler:get_letter(Pid, Value),
            Answer = jsx:encode([list_to_binary("letter")] ++ Letter);
        [{_, Dir}] ->
            [Pid] = State,
            {ok, {_Mailbox, Mails}} = mail_client:imap_select_mailbox(Pid,
                binary:bin_to_list(Dir), 15),
            Headers = muz_mail_handler:get_mail_number(Mails),
            Answer = jsx:encode([Dir] ++ Headers)
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
