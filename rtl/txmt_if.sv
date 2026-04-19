`timescale 1ns / 1ps
//---------------------------------------------------------
// UART_TRANSMITTER_INTERFACE
//---------------------------------------------------------

interface txmt_if(input bit clk);
	logic reset;
	logic wr_uart;
	logic [7:0] w_data;
	logic tx;
	logic tx_fifo_full;
	 
	clocking drv_cb @(posedge clk);
	default input #1 output #1;
		output reset;
		output wr_uart;
		output w_data;
		input tx_fifo_full;
	endclocking: drv_cb
	
	clocking mon_cb @(posedge clk);
	default input #1 output #1;
		input reset;
		input wr_uart;
		input tx;
		input w_data;
		input tx_fifo_full;
	endclocking: mon_cb
	
	modport DRV(clocking drv_cb);
	modport MON(clocking mon_cb);

endinterface: txmt_if