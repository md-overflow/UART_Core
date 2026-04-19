//--------------------------------------------------
// ENV CONFIGURATION CLASS
//--------------------------------------------------

class env_config extends uvm_object;
	`uvm_object_utils(env_config)
	
	rx_config rx_cfg;
	tx_config tx_cfg;
	
	bit has_scoreboard = 0;
	
	//constructor defaults
	extern function new(string name = "env_config");
endclass: env_config

function env_config::new(string name = "env_config");
	super.new(name);
endfunction