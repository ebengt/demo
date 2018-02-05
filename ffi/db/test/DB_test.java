import java.io.*;
import java.util.*;

import static org.junit.Assert.assertEquals;
import org.junit.Test;


public class DB_test {
	@Test
	public void
	create() {
		DB db = new DB();
		db.create( "kalle" );
		assertEquals( "kalle", db.name );
	}
	
	@Test
	public void
	ids() {
		DB db = new DB();
		db.create( "kalle" );
		assertEquals( new ArrayList<>(0), db.ids() );
	}
	
	@Test
	public void
	free_id() {
		DB db = new DB();
		db.create( "kalle" );
		assertEquals( 0, db.free_id() );
	}
	
	@Test
	public void
	write() {
		DB db = new DB();
		Record r;
		int i;
		db.create( "kalle" );
		i = db.free_id();
		r = new Record( i, "a command", 0 );
		db.write( r );
		assert( i != db.free_id() );
	}
	
	@Test
	public void
	read() throws IOException {
		DB db = new DB();
		Record r;
		int i;
		db.create( "kalle" );
		i = db.free_id();
		r = new Record( i, "a command", 0 );
		db.write( r );
		r = db.read( i );
		assertEquals( i, r.id );
		assertEquals( "a command", r.command );
		assertEquals( 0, r.result );
	}
	
	@Test
	public void
	close() throws IOException {
		File f = new File("kalle");
		f.delete();
		db_file( "kalle", "a command", 0 );
		assert( f.exists() );
	}
	
	@Test
	public void
	open() throws IOException {
		DB db = new DB();
		Record r;
		ArrayList<Integer> ids;
		Iterator<Integer> it;
		int i;
		db_file( "kalle", "a command", 0 );
		db.open( "kalle" );
		assertEquals( "kalle", db.name );
		ids = db.ids();
		it = ids.iterator();
		assert( it.hasNext() );
		i = it.next();
		r = db.read( i );
		assertEquals( i, r.id );
		assertEquals( "a command", r.command );
		assertEquals( 0, r.result );
	}
	
	@Test
	public void
	open_empty() throws IOException {
		DB db = new DB();
		File f = new File("kalle");
		f.delete();
		db.open( "kalle" );
		assertEquals( "kalle", db.name );
		assertEquals( 0, db.free_id() );
	}
	
	private void
	db_file( String name, String command, int result ) throws IOException {
		DB db = new DB();
		Record r;
		int i;
		db.create( name );
		i = db.free_id();
		r = new Record( i, command, result );
		db.write( r );
		db.close();
	}
}
