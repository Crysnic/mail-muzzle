-module(muz_mail_handler).

-export([mailbox_list/1, get_mail_number/1, get_letter/2]).

-include("muz.hrl").

get_letter(Pid, BinValue) ->
    Value = binary_to_integer(BinValue),
    {ok, [{_, Raw}]} = mail_client:imap_retrieve_message(Pid, Value),
    raw_to_mail(Raw).

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

%% Get list of letters headers
get_mail_number([]) ->
    [];
get_mail_number([H|T]) ->
    {Numb, [
        {"SIZE", _},
        {"FLAGS", Flags},
        {"ENVELOPE",
         {envelope, Date, Subj,
            [{address, From, _, _Nick, _Host}],
            _,
            _,
            _,
            _, _, _, _}}, _]} = H, 
    [[list_to_binary(integer_to_list(Numb)), 
      [list_to_binary(atom_to_list(X)) || X <- Flags], 
      list_to_binary(Date),
      list_to_binary(Subj),
      list_to_binary(From)]] ++ get_mail_number(T).

raw_to_mail(Raw) -> 
    {mail, From, To, _, _, Date, _, Thema, Body, _} =
        retrieve_util:raw_message_to_mail(Raw),
    [From, To, Date, Thema, Body].
