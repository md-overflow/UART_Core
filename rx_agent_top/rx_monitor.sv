//---------------------------------------------------------------------------
// RX MONITOR CLASS [EXTENDS FROM UVM_MONITOR]
//---------------------------------------------------------------------------
class rx_monitor extends uvm_monitor;
	`uvm_component_utils(rx_monitor)
	
	virtual rcvr_if.MON vif;
	rx_config m_cfg;
	rx_xtn data_rcvd;
	
	//Declare Analysis port handle
	uvm_analysis_port #(rx_xtn) monitor_port;
	
	// METHODS
	extern function new(string name = "rx_monitor", uvm_component parent);
	extern function void build_phase(uvm_phase phase);
	extern function void connect_phase(uvm_phase phase);
	extern task run_phase(uvm_phase phase);
	extern task collect_data();
//	extern function void report_phase(uvm_phase phase);
endclass: rx_monitor

function rx_monitor::new(string name = "rx_monitor", uvm_component parent);
	super.new(name, parent);
	monitor_port = new("monitor_port", this);
endfunction:new

function void rx_monitor::build_phase(uvm_phase phase);
	if(!uvm_config_db #(rx_config)::get(this,"","rx_config",m_cfg))
		`uvm_fatal("CONFIG","cannot get() m_cfg from uvm_config_db. Have you set() it?")
	super.build_phase(phase);
endfunction: build_phase

function void rx_monitor::connect_phase(uvm_phase phase);
	vif = m_cfg.vif;
endfunction: connect_phase

task rx_monitor::run_phase(uvm_phase phase);
	forever      
		begin
			collect_data();
		end
endtask: run_phase
	
task rx_monitor::collect_data();
	data_rcvd = rx_xtn::type_id::create("data_rcvd");
	
	wait(vif.mon_cb.rd_uart == 1)
	$display("@%0t: In_rx_monitor rd_uart=1", $time);
	@(vif.mon_cb);
	data_rcvd.rd_uart = vif.mon_cb.rd_uart;
	data_rcvd.r_data  = vif.mon_cb.r_data;
	
	data_rcvd.print();
	
	monitor_port.write(data_rcvd);
	
endtask: collect_data
