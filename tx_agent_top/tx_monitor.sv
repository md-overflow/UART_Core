//---------------------------------------------------------------------------
// TX MONITOR CLASS [EXTENDS FROM UVM_MONITOR]
//---------------------------------------------------------------------------
class tx_monitor extends uvm_monitor;
	`uvm_component_utils(tx_monitor)
	
	virtual txmt_if.MON vif;
	tx_config m_cfg;
	tx_xtn data_rcvd;
	
	int count;
	int i;
	//Declare Analysis port handle
	uvm_analysis_port #(tx_xtn) monitor_port;
	
	// METHODS
	extern function new(string name = "tx_monitor", uvm_component parent);
	extern function void build_phase(uvm_phase phase);
	extern function void connect_phase(uvm_phase phase);
	extern task run_phase(uvm_phase phase);
	extern task collect_data();
//	extern function void report_phase(uvm_phase phase);
endclass: tx_monitor

function tx_monitor::new(string name = "tx_monitor", uvm_component parent);
	super.new(name, parent);
	monitor_port = new("monitor_port", this);
endfunction:new

function void tx_monitor::build_phase(uvm_phase phase);
	if(!uvm_config_db #(tx_config)::get(this,"","tx_config",m_cfg))
		`uvm_fatal("CONFIG","cannot get() m_cfg from uvm_config_db. Have you set() it?")
	super.build_phase(phase);
endfunction: build_phase

function void tx_monitor::connect_phase(uvm_phase phase);
	vif = m_cfg.vif;
endfunction: connect_phase

task tx_monitor::run_phase(uvm_phase phase);
	forever      
		begin
			collect_data();
		end
endtask: run_phase
	
task tx_monitor::collect_data();
	data_rcvd = tx_xtn::type_id::create("data_rcvd");
	
	wait(vif.mon_cb.wr_uart == 1)
	$display("@%0t: In_tx_monitor wr_uart=1", $time);
	@(vif.mon_cb);
	data_rcvd.w_data  = vif.mon_cb.w_data;
	data_rcvd.wr_uart = vif.mon_cb.wr_uart;
	
	data_rcvd.print();
	
	monitor_port.write(data_rcvd);
	
endtask: collect_data
