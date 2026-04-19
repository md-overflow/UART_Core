//--------------------------------------------------
// RECEIVER AGENT CONFIGURATION
//--------------------------------------------------

class rx_config extends uvm_object;
	`uvm_object_utils(rx_config)
	
	virtual rcvr_if vif;
	uvm_active_passive_enum is_active = UVM_PASSIVE;
	
	
	//constructor defaults
	extern function new(string name = "rx_config");
endclass: rx_config

function rx_config::new(string name = "rx_config");
	super.new(name);
endfunction