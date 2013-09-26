-module(muz_mail_handler).

-export([mailbox_list/1, get_mail_number/1, raw_message_to_mail/2]).

-spec mailbox_list(Pid :: pid()) -> [MailBox :: tuple()]. 
mailbox_list(Pid) ->
    {ok, List} = mail_client:imap_list_mailbox(Pid),
    Inbox = get_mailbox_state(List, "INBOX", "UNSEEN"),
    Drafts = get_mailbox_state(List, "Drafts", "UNSEEN"),
    Sent = get_mailbox_state(List, "Sent", "UNSEEN"),
    Trash = get_mailbox_state(List, "Trash", "UNSEEN"),
    Spam = get_mailbox_state(List, "SPAM", "UNSEEN"),
    [Inbox, Drafts, Sent, Trash, Spam].

get_mail_number([]) ->
    [];
get_mail_number([H|T]) ->
    {Numb, _} = H, 
    [Numb] ++ get_mail_number(T).

raw_message_to_mail(Raw, Msg) ->
    {mail, From, To, _, _, Date, _, Thema, Body, _} = 
        retrieve_util:raw_message_to_mail(Raw),
    [{_, MailBox}] = jsx:decode(Msg),
    jsx:encode([MailBox, From, To, Date, Thema, Body]). 

%% Internal functions

get_mailbox_state([], MailBox, _State) ->
    {binary:list_to_bin(MailBox), [error, not_fined]};
get_mailbox_state([H|T], MailBox, State) ->
    case H of
        {MailBox, _, List} ->
            {State, Val} = lists:keyfind(State, 1, List),
            {binary:list_to_bin(MailBox), 
             [binary:list_to_bin(State), 
             binary:list_to_bin(Val)]};
        _ ->
            get_mailbox_state(T, MailBox, State)
    end.
