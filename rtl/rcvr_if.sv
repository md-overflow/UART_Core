`timescale 1ns / 1ps
//---------------------------------------------------------
// UART_RECEIVER_INTERFACE
//---------------------------------------------------------

interface rcvr_if(input bit clk);
	//logic reset;
	logic rd_uart;
	logic [7:0] r_data;
	logic rx;
	logic rx_fifo_full;
	logic rx_fifo_empty;
	 
	clocking drv_cb @(posedge clk);
	default input #1 output #1;
		//output reset;
		output rd_uart;
		output rx;
		input rx_fifo_full;
		input rx_fifo_empty;
	endclocking: drv_cb
	
	clocking mon_cb @(posedge clk);
	default input #1 output #1;
		//input reset;
		input rd_uart;
		input rx;
		input r_data;
		input rx_fifo_full;
		input rx_fifo_empty;
	endclocking: mon_cb
	
	modport DRV(clocking drv_cb);
	modport MON(clocking mon_cb);

endinterface: rcvr_if