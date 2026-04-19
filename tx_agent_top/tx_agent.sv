//--------------------------------------------------
// UART_TRANMITTER AGENT
//--------------------------------------------------

class tx_agent extends uvm_agent;
	`uvm_component_utils(tx_agent)
	
	//Declare a handle for tx_config 
	tx_config m_cfg;
	
	//Declare handles for transmitter driver, monitor, sequencer
	tx_driver drvh;
	tx_monitor monh;
	tx_sequencer seqrh;
	
	//Methods
	extern function new(string name = "tx_agent", uvm_component parent);
	extern function void build_phase(uvm_phase phase);
	extern function void connect_phase(uvm_phase phase);
	extern function void end_of_elaboration_phase(uvm_phase phase);
endclass: tx_agent

function tx_agent::new(string name = "tx_agent", uvm_component parent);
	super.new(name, parent);
endfunction: new

function void tx_agent::build_phase(uvm_phase phase);
	super.build_phase(phase);
	if(!uvm_config_db #(tx_config) :: get(this,"","tx_config",m_cfg))
		`uvm_fatal("CONFIG","Cannot get() m_cfg from uvm_config_db, have you set() it?")
	monh = tx_monitor::type_id::create("monh", this);
	if(m_cfg.is_active == UVM_ACTIVE)
		begin
			drvh  = tx_driver::type_id::create("drvh", this);
			seqrh = tx_sequencer::type_id::create("seqrh", this);
		end
endfunction: build_phase

function void tx_agent::connect_phase(uvm_phase phase);
	if(m_cfg.is_active == UVM_ACTIVE)
		begin
			drvh.seq_item_port.connect(seqrh.seq_item_export);
		end
endfunction: connect_phase

/*------------Print Topology-----------------*/
function void tx_agent::end_of_elaboration_phase(uvm_phase phase);
  uvm_top.print_topology();
endfunction: end_of_elaboration_phase 	 