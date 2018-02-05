import java.io.*;
import java.util.*;


public class DB {
	String name;
	ArrayList<Record> contents = new ArrayList<Record>();
	// External functions -------------------------------

	public void
	close() throws IOException {
		FileWriter fw = new FileWriter( name );
		BufferedWriter bw = new BufferedWriter( fw );
		file_write( bw, contents );
		bw.close();
		fw.close();
	}

	public void
	create( String file ) {
		name = file;
	}

	public ArrayList<Integer>
	ids() {
		ArrayList<Integer> ids = new ArrayList<Integer>();
		Iterator<Record> it = contents.iterator();
		Record r;
		while (it.hasNext()) {
			r = it.next();
			ids.add( r.id );
		}
		return ids;
	}

	public int
	free_id() {
		Iterator<Record> it = contents.iterator();
		Record r;
		int i = 0;
		while (it.hasNext()) {
			r = it.next();
			if (i <= r.id) {
				i = r.id + 1;
			}
		}
		return i;
	}

	public void
	open( String file ) throws IOException {
		create( file );
		try {
			Thread.sleep( 100 ); // Fake workload.
			FileReader fr = new FileReader( file );
			BufferedReader br = new BufferedReader( fr );
			file_read( br, contents );
			br.close();
			fr.close();
		}
		catch (FileNotFoundException e) {
			;
		}
		catch (InterruptedException e) {
			;
		}
	}

	public Record
	read( int id ) throws IOException {
		Iterator<Record> it = contents.iterator();
		Record r;
		while (it.hasNext()) {
			r = it.next();
			if (id == r.id) {
				return r;
			}
		}
		throw new IOException( "missing record" );
	}

	public void
	write( Record record ) {
		Iterator<Record> it = contents.iterator();
		Record r;
		Record old = null;
		while (it.hasNext()) {
			r = it.next();
			if (record.id == r.id) {
				old = r;
			}
		}
		if (old != null) {
			contents.remove( old );
		}
		contents.add( record );
	}

	// Internal functions -------------------------------
	private void
	file_read( BufferedReader br, ArrayList<Record> contents ) throws IOException {
		String line;
		String[] parts;
		Record record;
		while ((line = br.readLine()) != null) {
			parts = line.split(",");
			record = new Record( Integer.parseInt(parts[0]), parts[1], Integer.parseInt(parts[2]) );
			contents.add( record );
		}
	}

	private void
	file_write( BufferedWriter bw, ArrayList<Record> contents ) throws IOException {
		Iterator<Record> it = contents.iterator();
		String line;
		Record r;
		while (it.hasNext()) {
			r = it.next();
			line = Integer.toString(r.id) + "," + r.command + ","  + Integer.toString(r.result);
			bw.write( line );
			bw.newLine();
		}
	}
}
