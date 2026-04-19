package uart_test_pkg;

	import uvm_pkg::*;
	int no_of_trans = 7;
 
	`include "uvm_macros.svh"
	`include "tx_xtn.sv"
	`include "tx_config.sv"
	`include "rx_config.sv"
	`include "env_config.sv"
	`include "tx_driver.sv"
	`include "tx_monitor.sv"
	`include "tx_sequencer.sv"
	`include "tx_agent.sv"
	`include "tx_sequence.sv"

	`include "rx_xtn.sv"
	`include "rx_monitor.sv"
	`include "rx_sequencer.sv"
	`include "rx_sequence.sv"
	`include "rx_driver.sv"
	`include "rx_agent.sv"

//	`include "virtual_sequencer.sv"
//	`include "virtual_seqs.sv"
  	`include "uart_sb.sv"

	`include "uart_tb.sv"
	`include "uart_test_lib.sv"
	
endpackage: uart_test_pkg