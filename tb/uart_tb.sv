//---------------------------------------------------
// UART ENVIRONMENT CLASS
//---------------------------------------------------

class uart_tb extends uvm_env;
	`uvm_component_utils(uart_tb)
	
	//Declare handles for master_agent_top, slave_agent_top and scoreboard
	tx_agent tx_agth;
	rx_agent rx_agth;
	uart_sb sb_h;
	
	//Declare Environment configuration handle
	env_config m_cfg;
	
	//Methods
	extern function new(string name = "uart_tb", uvm_component parent);
	extern function void build_phase(uvm_phase phase);
	extern function void connect_phase(uvm_phase phase);
endclass: uart_tb

function uart_tb::new(string name = "uart_tb", uvm_component parent);
	super.new(name, parent);
endfunction: new

function void uart_tb::build_phase(uvm_phase phase);
	if(!uvm_config_db #(env_config)::get(this,"","env_config",m_cfg))
		`uvm_fatal("CONFIG","cannot get() m_cfg from uvm_config_db. Have you set() it?")
 
	tx_agth = tx_agent::type_id::create("tx_agth", this);
	uvm_config_db #(tx_config) :: set(this,"tx_agth*","tx_config", m_cfg.tx_cfg);
 
	rx_agth = rx_agent::type_id::create("rx_agth", this);
	uvm_config_db #(rx_config) :: set(this,"rx_agth*","rx_config", m_cfg.rx_cfg);
	
	if(m_cfg.has_scoreboard)
		begin
			sb_h = uart_sb::type_id::create("sb_h", this);
		end
endfunction: build_phase

function void uart_tb::connect_phase(uvm_phase phase);
	if(m_cfg.has_scoreboard)
		begin
			tx_agth.monh.monitor_port.connect(sb_h.tx_fifo.analysis_export);
			rx_agth.monh.monitor_port.connect(sb_h.rx_fifo.analysis_export);
		end
endfunction: connect_phase