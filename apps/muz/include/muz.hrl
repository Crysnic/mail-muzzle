-define(ERROR(Format), lager:log(error, self(), Format, [])).
-define(ERROR(Format, Args), lager:log(error, self(), Format, Args)).

-define(INFO(Format), lager:log(info, self(), Format, [])).
-define(INFO(Format, Args), lager:log(info, self(), Format, Args)).

-define(DEBUG(Format), lager:log(debug, self(), Format, [])).
-define(DEBUG(Format, Args), lager:log(debug, self(), Format, Args)).

-define(WARN(Format), lager:log(warning, self(), Format, [])).
-define(WARN(Format, Args), lager:log(warning, self(), Format, Args)).
