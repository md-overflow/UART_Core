`timescale 1ns / 1ps
//------------------------------------------------------------------------------------
// TOP MODULE
//------------------------------------------------------------------------------------
module top();
	import uvm_pkg::*;
	import uart_test_pkg::*;
	bit clock;
	
	initial begin
		clock = 1'b0;
		forever #10 clock = ~clock;
	end
	
	// Instantiate txmt and rcvr Interfaces
	txmt_if t_if(clock);
	rcvr_if r_if(clock);		
	
	// connect output tx to input rx pin for verification purposes
	wire tx2rx;
	
	//Instantiate DUT - UART Top Module
	uart_top DUT (	.clk(clock), 
					.reset(t_if.reset), 
					.rd_uart(r_if.rd_uart), 
					.wr_uart(t_if.wr_uart), 
					.rx(tx2rx), 
					.tx(tx2rx), 
					.w_data(t_if.w_data), 
					.r_data(r_if.r_data), 
					.tx_fifo_full(t_if.tx_fifo_full), 
					.rx_fifo_empty(r_if.rx_fifo_empty), 
					.rx_fifo_full(r_if.rx_fifo_full)
				 );
				   
	initial begin
		uvm_config_db #(virtual txmt_if) :: set(null,"*","vif1", t_if);
		uvm_config_db #(virtual rcvr_if) :: set(null,"*","vif2", r_if);
		
		//Call run_test
		run_test();
	end
	
endmodule: top