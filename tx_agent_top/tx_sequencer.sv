//------------------------------------------------------------------------
// TX SEQUENCER
//------------------------------------------------------------------------

class tx_sequencer extends uvm_sequencer #(tx_xtn);
	`uvm_component_utils(tx_sequencer)
	
	// METHODS
	extern function new(string name = "tx_sequencer", uvm_component parent);
endclass: tx_sequencer

function tx_sequencer::new(string name = "tx_sequencer", uvm_component parent);
	super.new(name, parent);
endfunction: new