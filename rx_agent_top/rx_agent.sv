//--------------------------------------------------
// UART_RECEIVER AGENT
//--------------------------------------------------

class rx_agent extends uvm_agent;
	`uvm_component_utils(rx_agent)
	
	//Declare a handle for rx_config 
	rx_config m_cfg;
	
	//Declare handles for receiver driver, monitor, sequencer
	rx_driver drvh;
	rx_monitor monh;
	rx_sequencer seqrh;
	
	//Methods
	extern function new(string name = "rx_agent", uvm_component parent);
	extern function void build_phase(uvm_phase phase);
	extern function void connect_phase(uvm_phase phase);
endclass: rx_agent

function rx_agent::new(string name = "rx_agent", uvm_component parent);
	super.new(name, parent);
endfunction: new

function void rx_agent::build_phase(uvm_phase phase);
	super.build_phase(phase);
	if(!uvm_config_db #(rx_config) :: get(this,"","rx_config",m_cfg))
		`uvm_fatal("CONFIG","Cannot get() m_cfg from uvm_config_db, have you set() it?")
	monh = rx_monitor::type_id::create("monh", this);
	if(m_cfg.is_active == UVM_ACTIVE)
		begin
			drvh  = rx_driver::type_id::create("drvh", this);
			seqrh = rx_sequencer::type_id::create("seqrh", this);
		end
endfunction: build_phase

function void rx_agent::connect_phase(uvm_phase phase);
	if(m_cfg.is_active == UVM_ACTIVE)
		begin
			drvh.seq_item_port.connect(seqrh.seq_item_export);
		end
endfunction: connect_phase