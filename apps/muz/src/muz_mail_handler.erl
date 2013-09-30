-module(muz_mail_handler).

-export([mailbox_list/1, get_mail_number/1, get_letter/2]).

-include("muz.hrl").

get_letter(_Pid, []) ->
    [];
get_letter(Pid, [H|T]) ->
    {ok, [{H, Raw}]} = mail_client:imap_retrieve_message(Pid, H),
    [list_to_binary(integer_to_list(H)), raw_to_mail(Raw)] ++
        get_letter(Pid, T).

-spec mailbox_list(Pid :: pid()) -> [MailBox :: tuple()]. 
mailbox_list(Pid) ->
    {ok, List} = mail_client:imap_list_mailbox(Pid),
    [list_to_binary("mailbox")] ++  full_mailbox_list(List).

full_mailbox_list([]) ->
    [];
full_mailbox_list([H|T]) ->
    {MailBox, _, List} = H,
    [list_to_binary(MailBox), keyfind(["UNSEEN", "MESSAGES"], List)] ++
        full_mailbox_list(T).

keyfind([], _List) ->
    [];
keyfind([H|T], List) ->
    {H, Val} = lists:keyfind(H, 1, List),
    [{list_to_binary(H), list_to_binary(Val)}] ++ keyfind(T, List).

get_mail_number([]) ->
    [];
get_mail_number([H|T]) ->
    {Numb, _} = H, 
    [Numb] ++ get_mail_number(T).

raw_to_mail(Raw) -> 
    {mail, From, To, _, _, Date, _, Thema, Body, _} =
        retrieve_util:raw_message_to_mail(Raw),
    [From, To, Date, Thema, Body].
