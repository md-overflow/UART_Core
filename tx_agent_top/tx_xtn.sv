//------------------------------------------------------------
// DESTINATION TRANSACTION CLASS
//------------------------------------------------------------  
class tx_xtn extends uvm_sequence_item;
  `uvm_object_utils(tx_xtn)
	
	bit reset;
	rand bit wr_uart;
	rand bit [7:0] w_data;
	//bit [7:0] tx_reg;
	bit tx_fifo_full;
  
	//declare count for transmission for BR = 19200
	int tx_count;
  
	// For monitoring no_of transactions 
	static int trans_id;

	// METHODS
	extern function new(string name = "tx_xtn");
	extern function void do_print(uvm_printer printer);
	extern function void post_randomize(); 
endclass: tx_xtn

function tx_xtn::new(string name = "tx_xtn");
	super.new(name);
endfunction: new

function void  tx_xtn::do_print (uvm_printer printer);
	super.do_print(printer);
   
    //              	  srting name   	  bitstream value       	size    radix for printing
    
    printer.print_field( "reset", 	        	this.reset,          	'1,		   UVM_HEX);
    printer.print_field( "tx_fifo_full", 	    this.tx_fifo_full,      '1,	       UVM_HEX);
    printer.print_field( "wr_uart",             this.wr_uart,           '1,		   UVM_HEX);
//    printer.print_field( "tx_reg",           	this.tx_reg,       		8,		   UVM_HEX);
	printer.print_field( "w_data",           	this.w_data,       		 8,		   UVM_HEX);

endfunction:do_print

function void tx_xtn::post_randomize();
	trans_id++;
  //this.print();
endfunction: post_randomize