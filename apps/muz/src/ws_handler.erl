-module(ws_handler).
-behaviour(cowboy_websocket_handler).

-export([init/3]).
-export([websocket_init/3, websocket_handle/3, websocket_info/3,
         websocket_terminate/3]).

-include("muz.hrl").

init({tcp, http}, _Req, _Opts) ->
    {upgrade, protocol, cowboy_websocket}.

websocket_init(_TransportName, Req, _Opts) ->
    {ok, Req, undefined_state}.

websocket_handle({text, Msg}, Req, State) ->
    {reply, {text, <<"That's what she said! ", Msg/binary>>}, Req, State};
websocket_handle(_Data, Req, State) ->
    ?INFO("Handle: ~p", [Req]),
    {ok, Req, State}.

websocket_info(_Info, Req, State) ->
    {ok, Req, State}.

websocket_terminate(_Reason, _Req, _State) ->
    ok.
