-module(muz_mail_handler).

-export([mailbox_list/1]).

-spec mailbox_list(Pid :: pid()) -> [MailBox :: tuple()]. 
mailbox_list(Pid) ->
    {ok, List} = mail_client:imap_list_mailbox(Pid),
    Inbox = get_mailbox_state(List, "INBOX", "UNSEEN"),
    Drafts = get_mailbox_state(List, "Drafts", "UNSEEN"),
    Sent = get_mailbox_state(List, "Sent", "UNSEEN"),
    Trash = get_mailbox_state(List, "Trash", "UNSEEN"),
    Spam = get_mailbox_state(List, "SPAM", "UNSEEN"),
    [Inbox, Drafts, Sent, Trash, Spam].

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
