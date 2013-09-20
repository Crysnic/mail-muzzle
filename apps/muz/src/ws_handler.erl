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
    ?INFO("Websocket init: ~p", [Req]),
    {ok, Req, undefined_state, hibernate}.

websocket_handle({text, Msg}, Req, State) ->
    ?INFO("Handle text"),
    {reply, {text, <<"That's what she said! ", Msg/binary>>}, Req, State};
websocket_handle(_Data, Req, State) ->
    ?INFO("Handle: ~p", [Req]),
    {ok, Req, State}.

websocket_info(_Info, Req, State) ->
    ?INFO("Websocket info"),
    {ok, Req, State}.

websocket_terminate(_Reason, _Req, _State) ->
    ok.
