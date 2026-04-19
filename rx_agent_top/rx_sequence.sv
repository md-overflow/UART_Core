//-------------------------------------------------------------------
// RX SEQUENCE CLASS
//-------------------------------------------------------------------
class rx_base_seqs extends uvm_sequence #(rx_xtn);
	`uvm_object_utils(rx_base_seqs)
	
	// METHODS
	extern function new(string name = "rx_base_seqs");
endclass: rx_base_seqs

function rx_base_seqs::new(string name = "rx_base_seqs");
	super.new(name);
endfunction:new
//-------------------------------------------------------------------
// TX READ-SEQUENCE CLASS
//-------------------------------------------------------------------
class rx_read_sequence extends rx_base_seqs;
	`uvm_object_utils(rx_read_sequence)
	
	// METHODS
	extern function new(string name = "rx_read_sequence");
	extern task body();
endclass: rx_read_sequence

function rx_read_sequence::new(string name = "rx_read_sequence");
	super.new(name);
endfunction:new

task rx_read_sequence::body();
	repeat(no_of_trans)
		begin
			req = rx_xtn::type_id::create("req");
			start_item(req);
			assert(req.randomize() with {rd_uart == 1'b1;});
			finish_item(req);
		end
endtask: body



