-module( tdd_config ).

-export( [export/1] ).

export( Name ) ->
	Init_config = tdd_init:config( Name ),
	string( Init_config ).



string( Init_config ) ->
	Sts = [string_tuple(X) || X <- Init_config],
	"[" ++ string:join( Sts, "\n" ) ++ "]".

string_tuple( {Key, Value} ) -> lists:flatten( io_lib:format("{~p, ~p}", [Key, Value]) ).

