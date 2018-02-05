-module( target_SUITE ).

-export( [all/0, init_per_suite/1, target/1] ).


all() -> [target].

init_per_suite( Config ) ->
	os:cmd("epmd"),
	net_kernel:start( [kalle, shortnames] ),
 	{ok, Directory} = file:get_cwd(),
	File = "kalle",
	file:delete( File ),
	{ok, DB} = dist:java_db_setup( Directory, File ),
	{ok, P} = dist:python_build_setup( Directory ),
	[{dist_setup, {File, DB, P}} | Config].


target( Config ) ->
	{File, DB, P} = proplists:get_value( dist_setup, Config ),
	dist:target(DB, P, "echo"),
	java:call( DB, close, [] ),
	{ok, B} = file:read_file( File ),
	true = (binary:match(B, <<"echo">>) =/= nomatch).
