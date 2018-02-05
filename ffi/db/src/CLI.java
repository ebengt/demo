import java.io.*;
import java.util.*;


public class CLI {
    public static void
    main( String[] argv ) throws IOException {
	String s;

	switch (argv[0]) {
	case "free_id": s = free_id( argv[1] );
		break;
	case "write":
		String command = argv[4];
		for (int i = 5; i < argv.length; i++) {
			command = command + " " + argv[i];
		}
		s = write( argv[1], argv[2], argv[3], command );
		break;
	default: s = "ERROR";
	}
	System.out.println( s );
    }


    private static String
    free_id( String name ) throws IOException {
	DB db;
	int i;

	db = new DB();
	db.open( name );
	i = db.free_id();
	db.close();
	return Integer.toString(i);
    }

    private static String
    write( String name, String id, String result, String command ) throws IOException {
	DB db;
	
System.out.println( "name " + name );
System.out.println( id );
System.out.println( result );
System.out.println( command );
	db = new DB();
	db.open( name );
	db.write( new Record( Integer.parseInt(id), command, Integer.parseInt(result)) );
	db.close();
	return "ok";
    }

}
