-module(muz_app).
-behaviour(application).

-export([start/2, stop/1]).

-include("muz.hrl").
%% Api

start(_Type, _Args) ->
    Dispatch = dispatch_rules(),
    Port = muz_lib:get_option(port),
    IP = muz_lib:get_option(ip),
    {ok, _} = cowboy:start_https(https, 100, [
            {port, Port},
            {ip, IP},
            {certfile, filename:join(
                code:priv_dir(muz), muz_lib:get_option(certfile))},
            {keyfile, filename:join(
                code:priv_dir(muz), muz_lib:get_option(keyfile))},
            {ciphers, ciphers()} 
        ],
        [{env, [{dispatch, Dispatch}]}]
    ),
    ?INFO("Starting web server on https://~s:~p", 
        [inet_parse:ntoa(IP), Port]),
    muz_sup:start_link().

stop(_State) ->
    ok.

%% Application functions

dispatch_rules() ->
    Static = fun(Type) ->
        {lists:append(["/", Type, "/[...]"]), cowboy_static, [
            {directory, {priv_dir, muz, [list_to_binary(Type)]}},
            {mimetypes, {fun mimetypes:path_to_mimes/2, default}}]    
        }
    end,
    cowboy_router:compile([
        {'_',[
            Static("css"),
            Static("js"),
            Static("img"),
            {"/", cowboy_static, [
                {directory, {priv_dir, muz, []}},
                {file, "index.html"},
                {mimetypes, {fun mimetypes:path_to_mimes/2, default}}
            ]},
            {"/auth", auth_handler, []}
        ]}
    ]).

ciphers() ->
    [
        {dhe_rsa,aes_256_cbc,sha256},
        {dhe_dss,aes_256_cbc,sha256},
        {rsa,aes_256_cbc,sha256},
        {dhe_rsa,aes_128_cbc,sha256},
        {dhe_dss,aes_128_cbc,sha256},
        {rsa,aes_128_cbc,sha256},
        {dhe_rsa,aes_256_cbc,sha},
        {dhe_dss,aes_256_cbc,sha},
        {rsa,aes_256_cbc,sha},
        {dhe_rsa,'3des_ede_cbc',sha},
        {dhe_dss,'3des_ede_cbc',sha},
        {rsa,'3des_ede_cbc',sha},
        {dhe_rsa,aes_128_cbc,sha},
        {dhe_dss,aes_128_cbc,sha},
        {rsa,aes_128_cbc,sha},
        {rsa,rc4_128,sha},
        {rsa,rc4_128,md5},
        {dhe_rsa,des_cbc,sha},
        {rsa,des_cbc,sha}
    ].
