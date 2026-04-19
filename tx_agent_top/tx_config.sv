//--------------------------------------------------
// TRANSMITTER AGENT CONFIGURATION
//--------------------------------------------------

class tx_config extends uvm_object;
	`uvm_object_utils(tx_config)
	
	virtual txmt_if vif;
	uvm_active_passive_enum is_active = UVM_PASSIVE;
	
	
	//constructor defaults
	extern function new(string name = "tx_config");
endclass: tx_config

function tx_config::new(string name = "tx_config");
	super.new(name);
endfunction