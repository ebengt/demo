-module( dist ).

-export( [java_db_setup/2, main/1, python_build_setup/1, setup/1, target/3] ).


java_db_setup( Directory, Datafile )  ->
	{ok, Libs} = java_libs( Directory ),
	%% Timeouts for slow computer.
	{ok, J} = java:start_node([{add_to_java_classpath,Libs}, {ping_timeout,10000},{connection_timeout,10000}]),
	DB = java:new( J, 'DB', [] ),
	java:call( DB, open, [Datafile] ),
	{ok, DB}.

main( [Run, Targets_file] ) ->
	{ok, DB, P} = dist:setup( Run ),
	[dist:target(DB, P, X) || X <- targets(Targets_file)],
	java:call( DB, close, [] ).

python_build_setup( Directory ) ->
	{ok, Lib} = python_libs( Directory ),
	%% Python subprocess module uses file descriptors 0 and 1.
	{ok, P} = python:start( [nouse_stdio, {python_path, Lib}] ),
	python:call( P, command, prepare, [] ),
	{ok, P}.

setup( Datafile ) -> 
	{ok, Directory} = file:get_cwd(),
	{ok, DB} = java_db_setup( Directory, Datafile ),
	{ok, P} = python_build_setup( Directory ),
	{ok, DB, P}.

target( DB, P, Command ) ->
	Id = db_id( DB ),
	Result = build( P, Command ),
	db_write( DB, Id, Result, Command ).
	
%% Internal functions

build( P, Command ) -> python:call( P, command, result, [binary:list_to_bin(Command)] ).

db_id( DB ) -> java:call(DB, free_id, [] ).

db_write( DB, Id, Result, Command ) ->
	Record = java:new( java:node_id(DB), 'Record', [Id, Command, Result] ),
	java:call( DB, write, [Record] ).


java_libs( Directory ) ->
	DB_lib = java_lib_db( Directory ),
	java_lib_priv( DB_lib, Directory ).

java_lib_db( "/" ) -> error;
java_lib_db( Directory ) ->
	DBL = filename:join( [Directory, "db", "lib"] ),
	java_lib_db_ok( filelib:is_dir(DBL), DBL, Directory ).

java_lib_db_ok( true, DBL, _Directory ) -> {ok, DBL};
java_lib_db_ok( false, _DBL, Directory ) -> java_lib_db( filename:dirname(Directory) ).

java_lib_priv( error, _Directory ) -> error;
java_lib_priv( {ok, DB}, Directory ) ->
	%% java_erlang can find the JAR file automatically if it is in the right place.
	%% escript stops this. If this was not a demo I would tell the system where the JAR is.
	java_lib_priv_auto( filelib:is_dir(code:priv_dir(java_erlang)), DB, Directory ).

java_lib_priv_auto( true, DB, _D ) -> {ok, [DB]};
java_lib_priv_auto( false, DB, Directory ) ->
	Jars = filelib:fold_files( Directory, "JavaErlang.jar", true, fun(F, Acc) -> [F|Acc] end, [] ),
	java_lib_priv_manual( Jars, DB ).

java_lib_priv_manual( [Jar | _], DB ) -> {ok, [Jar, DB]};
java_lib_priv_manual( _, _DB ) -> error.


python_libs( Directory ) ->
	BL = python_lib_build( Directory ),
	python_lib_erlport( BL, Directory ).

python_lib_build( "/" ) -> error;
python_lib_build( Directory ) ->
	BL = filename:join( [Directory, "build"] ),
	python_lib_build_ok( filelib:is_dir(BL), BL, Directory ).

python_lib_build_ok( true, BL, _Directory ) -> {ok, BL};
python_lib_build_ok( false, _BL, Directory ) -> python_lib_build( filename:dirname(Directory) ).

python_lib_erlport( error, _Directory ) -> error;
python_lib_erlport( {ok, BL}, Directory ) ->
	%% erlport can find erlport Python files automatically if they are in the right place.
	%% escript stops this. If this was not a demo I would tell the system where the Python lib is.
	python_lib_erlport_auto( filelib:is_dir(code:priv_dir(erlport)), BL, Directory ).

python_lib_erlport_auto( true, BL, _D ) -> {ok, [BL]};
python_lib_erlport_auto( false, BL, Directory ) ->
	Ps = filelib:fold_files( Directory, "__init__.py", true, fun(F, Acc) -> [F|Acc] end, [] ),
	python_lib_erlport_manual( python_lib_erlport_p2(Ps), BL ).

python_lib_erlport_p2( Ps ) -> [X || X <- Ps, python_lib_erlport_p2_ok(X)].
python_lib_erlport_p2_ok( EPinit ) ->
	EP = filename:dirname(EPinit),
	P2 = filename:dirname(EP),
	Priv = filename:dirname(P2),
	filename:basename(EP) =:= "erlport" andalso filename:basename(P2) =:= "python2" andalso filename:basename(Priv) =:= "priv".

python_lib_erlport_manual( [EPinit | _], BL ) -> {ok, filename:dirname(filename:dirname(EPinit)) ++ ":" ++ BL};
python_lib_erlport_manual( _, _DB ) -> error.




targets( File ) ->
	{ok, B} = file:read_file( File ),
	[binary:bin_to_list(X) || X <- binary:split(B, <<"\n">>, [global]), X =/= <<>>].
