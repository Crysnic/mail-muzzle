-module(muz_mail_handler).

-export([mailbox_list/1]).

-spec mailbox_list(Pid :: pid()) -> 
    {MailBox :: string(), 
     State :: string(),
     Value :: string()} | {error, Reason :: atom()}. 
mailbox_list(Pid) ->
    {ok, List} = mail_client:imap_list_mailbox(Pid),
        case get_mailbox_state(List, "INBOX") of
            {"UNSEEN", Val} ->
                {"INBOX", "UNSEEN", Val};
            {error, Reason} ->
                {error, Reason}
        end.

-spec get_mailbox_state(list(), MailBox :: string()) -> 
    {MailBox :: string(), Value :: string()}.
get_mailbox_state(List, MailBox) ->
    case MailBox of
	"INBOX" ->
            get_mailbox_state(List, MailBox, "UNSEEN")
    end.

-spec get_mailbox_state(list(), string(), string()) ->
    {MailBox :: string(), Value :: string()}.
get_mailbox_state([], _MailBox, _State) ->
    {error, not_fined};
get_mailbox_state([H|T], MailBox, State) ->
    case H of
        {MailBox, _, List} ->
            lists:keyfind(State, 1, List);
        _ ->
            get_mailbox_state(T, MailBox, State)
    end.
