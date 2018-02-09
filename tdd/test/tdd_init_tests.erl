-module( tdd_init_tests ).

-include_lib( "eunit/include/eunit.hrl" ).

%% Tests for ../src/tdd_init.erl

gustav_test_() ->
	{timeout,
		60,
		fun() ->
			Config = tdd_init:config( gustav ),
			Keys = proplists:get_keys( Config ),
			Expected = gustav,
			?assert( lists:member(Expected, Keys) ),
			?assertEqual( [], lists:delete(Expected, Keys) )
		end
	}.

kalle_test_() ->
	{timeout,
		60,
		fun() ->
			Content = tdd_init:config( kalle ),
			Keys = maps:keys( Content ),
			Expected1 = kalle1,
			Expected2 = kalle2,
			?assert( lists:member(Expected1, Keys) ),
			?assert( lists:member(Expected2, Keys) ),
			?assertEqual( [], (Keys -- [Expected1, Expected2]) )
		end
	}.
