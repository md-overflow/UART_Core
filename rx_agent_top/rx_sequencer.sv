//------------------------------------------------------------------------
// RX SEQUENCER
//------------------------------------------------------------------------

class rx_sequencer extends uvm_sequencer #(rx_xtn);
	`uvm_component_utils(rx_sequencer)
	
	// METHODS
	extern function new(string name = "rx_sequencer", uvm_component parent);
endclass: rx_sequencer

function rx_sequencer::new(string name = "rx_sequencer", uvm_component parent);
	super.new(name, parent);
endfunction: new