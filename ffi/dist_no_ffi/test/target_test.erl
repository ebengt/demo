-module( target_test ).

-include_lib( "eunit/include/eunit.hrl" ).


setup_test() -> dist:setup().

target_test() ->
	File = "kalle",
	file:delete( File ),
	dist:target( File, "echo" ),
	{ok, B} = file:read_file( File ),
	?assert( binary:match(B, <<"echo">>) =/= nomatch).
