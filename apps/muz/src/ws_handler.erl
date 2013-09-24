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
            if
                Email == undefined ->
                    Answer = "[\"error\",\"undefined email/passwd\"]";
                true ->
                    {ok, Pid} = mail_client:open_retrieve_session(
                        "ipv6.dp.ua", 993, Email, Passwd, [ssl, imap]),
                    {MailBox, MbState, Value} = 
                        muz_mail_handler:mailbox_list(Pid),
                    %%Answer = "[\"" ++ MailBox ++"\",[\"" ++ MbState ++ 
                    %%    "\",\"" ++ Value ++"\"]]"
                    Answer = jsx:encode([binary:list_to_bin(Email), 
                                        binary:list_to_bin(MailBox),
                                        [binary:list_to_bin(MbState),
                                        binary:list_to_bin(Value)]])
            end
    end, 
    {reply, {text, Answer}, Req, State, hibernate};
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
