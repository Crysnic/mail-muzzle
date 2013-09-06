-module(muz_lib).

%% API
-export([get_option/1, get_option/2]).

-spec get_option(Option :: atom()) -> undefined | term().
get_option(Option) ->
    get_option(Option, undefined).

-spec get_option(Option :: atom(), Default :: term()) -> term().
get_option(Option, Default) ->
    application:get_env(muz, Option, Default).
