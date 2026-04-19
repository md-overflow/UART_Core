//------------------------------------------------------------
// RECEIVER TRANSACTION CLASS
//------------------------------------------------------------  
class rx_xtn extends uvm_sequence_item;
  `uvm_object_utils(rx_xtn)
	
  rand bit rd_uart;
  bit [7:0] r_data;
  //rand bit rx;
  bit rx_fifo_full;
  bit rx_fifo_empty;
  	
  //declare count for reception for BR = 19200
  int rx_count;
  
  //static int trans_id;
	
	// METHODS
	extern function new(string name = "rx_xtn");
	extern function void do_print(uvm_printer printer);
	extern function void post_randomize(); 
endclass: rx_xtn

function rx_xtn::new(string name = "rx_xtn");
	super.new(name);
endfunction: new

function void  rx_xtn::do_print (uvm_printer printer);
	super.do_print(printer);
   
    //              	  srting name   	  	bitstream value       size    radix for printing
    
    printer.print_field( "r_data",          			this.r_data,          	 	 8,		   UVM_HEX);
	printer.print_field( "rd_uart", 	        		this.rd_uart,        		'1,	       UVM_HEX);
//	printer.print_field( "rx", 			        		this.rx,        			'1,		   UVM_HEX);
    printer.print_field( "rx_fifo_full",             	this.rx_fifo_full,          '1,		   UVM_HEX);
    printer.print_field( "rx_fifo_empty",           	this.rx_fifo_empty,       	'1,		   UVM_HEX);

endfunction:do_print

function void rx_xtn::post_randomize();
	//trans_id++;
  //this.print();
endfunction: post_randomize