//-----------------------------------------------------
// UART TEST LIBRARY CLASS
//-----------------------------------------------------

class uart_base_test extends uvm_test;
	`uvm_component_utils(uart_base_test)
	
	//Declare TX and RX configuration handles
	tx_config tx_cfg;
	rx_config rx_cfg;
	
	//Declare Environment configuration handle
	env_config m_cfg;
	
	// Declare environment handle
	uart_tb envh;
	
	//Methods
	extern function new(string name = "uart_base_test", uvm_component parent);
	extern function void build_phase(uvm_phase phase);
endclass: uart_base_test

function uart_base_test::new(string name = "uart_base_test", uvm_component parent);
	super.new(name, parent);
endfunction

function void uart_base_test::build_phase(uvm_phase phase);
	tx_cfg = tx_config::type_id::create("tx_cfg");
	if(!uvm_config_db #(virtual txmt_if) :: get(this,"","vif1",tx_cfg.vif))
		`uvm_fatal("CONFIG","Could not get() the virtual interface, have you set() it?")
	tx_cfg.is_active = UVM_ACTIVE;
	
	rx_cfg = rx_config::type_id::create("rx_cfg");
	if(!uvm_config_db #(virtual rcvr_if) :: get(this,"","vif2",rx_cfg.vif))
		`uvm_fatal("CONFIG","Could not get() the virtual interface, have you set() it?")
	rx_cfg.is_active = UVM_ACTIVE;
	
	//create object of env_config class
	m_cfg = env_config::type_id::create("m_cfg");
	
	m_cfg.tx_cfg = tx_cfg;
	m_cfg.rx_cfg = rx_cfg;
    m_cfg.has_scoreboard = 1;
	
	uvm_config_db #(env_config) :: set(this,"*","env_config",m_cfg);
	
	envh = uart_tb::type_id::create("envh", this);
	
endfunction: build_phase

//-----------------------------------------------------
// TX WRITE TEST CLASS
//-----------------------------------------------------

class tx_write_rx_read_test extends uart_base_test;
	`uvm_component_utils(tx_write_rx_read_test)
	
	tx_write_sequence tx_write_seqs;
	rx_read_sequence rx_read_seqs;
	
	extern function new(string name = "tx_write_rx_read_test", uvm_component parent);
	extern function void build_phase(uvm_phase phase);
	extern task run_phase(uvm_phase phase);
endclass: tx_write_rx_read_test

function tx_write_rx_read_test :: new(string name = "tx_write_rx_read_test", uvm_component parent);
	super.new(name, parent);
endfunction: new

function void tx_write_rx_read_test::build_phase(uvm_phase phase);
	super.build_phase(phase);
endfunction: build_phase

task tx_write_rx_read_test::run_phase(uvm_phase phase);
tx_write_seqs = tx_write_sequence::type_id::create("tx_write_seqs");
rx_read_seqs = rx_read_sequence::type_id::create("rx_read_seqs");

	phase.raise_objection(this);
	fork
		tx_write_seqs.start(envh.tx_agth.seqrh);
		rx_read_seqs.start(envh.rx_agth.seqrh);
	join
	phase.drop_objection(this);
endtask: run_phase