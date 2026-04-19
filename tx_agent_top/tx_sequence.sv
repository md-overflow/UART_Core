//-------------------------------------------------------------------
// TX SEQUENCE CLASS
//-------------------------------------------------------------------
class tx_base_seqs extends uvm_sequence #(tx_xtn);
	`uvm_object_utils(tx_base_seqs)
	
	// METHODS
	extern function new(string name = "tx_base_seqs");
endclass: tx_base_seqs

function tx_base_seqs::new(string name = "tx_base_seqs");
	super.new(name);
endfunction:new


//-------------------------------------------------------------------
// TX WRITE-SEQUENCE CLASS
//-------------------------------------------------------------------
class tx_write_sequence extends tx_base_seqs;
	`uvm_object_utils(tx_write_sequence)
	
	// METHODS
	extern function new(string name = "tx_write_sequence");
	extern task body();
endclass: tx_write_sequence

function tx_write_sequence::new(string name = "tx_write_sequence");
	super.new(name);
endfunction:new

task tx_write_sequence::body();
	repeat(no_of_trans)
		begin
			req = tx_xtn::type_id::create("req");
			start_item(req);
			assert(req.randomize() with {wr_uart == 1'b1;});
			finish_item(req);
		end
endtask: body