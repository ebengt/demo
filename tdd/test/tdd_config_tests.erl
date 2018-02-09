-module( tdd_config_tests ).

-include_lib( "eunit/include/eunit.hrl" ).

%% Tests for ../src/tdd_config.erl

gustav_test_() ->
	{timeout,
		60,
		fun() ->
			Export = tdd_config:export( gustav ),
			?assertEqual( Export, "[{gustav, 1}]" )
		end
	}.
