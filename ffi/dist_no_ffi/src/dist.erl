-module( dist ).

-export( [main/1, setup/0, target/2] ).


main( [Run, Targets_file] ) ->
	dist:setup(),
	[dist:target(Run, X) || X <- targets(Targets_file)].

-spec setup() -> integer().
setup() -> 
	{ok, Directory} = file:get_cwd(),
	true = java_db_script( Directory ),
	true = python_build_script( Directory ).

target( Run, Command ) ->
	Id_output = os:cmd( db_id(Run) ),
	0 = string:str( Id_output, "ERROR" ),
	Id = lists:last( string:tokens(Id_output, "\n") ),
	Build_output = os:cmd( build(Command) ),
	Result = lists:last( string:tokens(Build_output, "\n") ),
	Write_output = os:cmd( db_write(Run, Id, Result, Command) ),
	0 = string:str( Write_output, "ERROR" ).

%% Internal functions

build( Command ) ->
	lists:flatten( io_lib:format("python ~s ~s ; echo $? ", [os:getenv( "FFIDEMO_PYTHON_BUILD_COMMAND"), Command]) ).

db_id( Run ) ->
	lists:flatten( io_lib:format("~s free_id ~s ", [os:getenv( "FFIDEMO_JAVA_DB_COMMAND"), Run]) ).

db_write( Run, Id, Result, Command ) ->
	lists:flatten( io_lib:format("~s write ~s ~s ~s ~s", [os:getenv( "FFIDEMO_JAVA_DB_COMMAND"), Run, Id, Result, Command]) ).


java_db_script( "/" ) -> error;
java_db_script( Directory ) ->
	DBC = filename:join( [Directory, "db", "db"] ),
	java_db_script_ok( filelib:is_regular(DBC), DBC, Directory ).

java_db_script_ok( true, DBC, _Directory ) -> os:putenv( "FFIDEMO_JAVA_DB_COMMAND", DBC );
java_db_script_ok( false, _DBC, Directory ) -> java_db_script( filename:dirname(Directory) ).


python_build_script( "/" ) -> error;
python_build_script( Directory ) ->
	BC = filename:join( [Directory, "build", "command.py"] ),
	python_build_script_ok( filelib:is_regular(BC), BC, Directory ).

python_build_script_ok( true, BC, _Directory ) -> os:putenv( "FFIDEMO_PYTHON_BUILD_COMMAND", BC );
python_build_script_ok( false, _BC, Directory ) -> python_build_script( filename:dirname(Directory) ).


targets( File ) ->
	{ok, B} = file:read_file( File ),
	[binary:bin_to_list(X) || X <- binary:split(B, <<"\n">>, [global]), X =/= <<>>].
