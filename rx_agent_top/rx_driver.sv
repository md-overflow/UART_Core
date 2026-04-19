//---------------------------------------------------------------------------
// RX DRIVER CLASS [EXTENDS FROM UVM_DRIVER]
//---------------------------------------------------------------------------
class rx_driver extends uvm_driver #(rx_xtn);
	`uvm_component_utils(rx_driver)
	
	rx_config m_cfg;
	virtual rcvr_if.DRV vif; 
	
	
	// METHODS
	extern function new(string name = "rx_driver", uvm_component parent);
	extern function void build_phase(uvm_phase phase);
	extern function void connect_phase(uvm_phase phase);
	extern task run_phase(uvm_phase phase);
	extern task send_to_dut(rx_xtn xtn);
	extern function void report_phase(uvm_phase phase);
endclass: rx_driver

function rx_driver::new(string name = "rx_driver", uvm_component parent);
	super.new(name, parent);
endfunction: new

function void rx_driver::build_phase(uvm_phase phase);
	if(!uvm_config_db #(rx_config)::get(this,"","rx_config",m_cfg))
		`uvm_fatal("CONFIG","cannot get() m_cfg from uvm_config_db. Have you set() it?")
endfunction: build_phase

function void rx_driver::connect_phase(uvm_phase phase);
	vif = m_cfg.vif;
endfunction: connect_phase


task rx_driver::run_phase(uvm_phase phase);
repeat(2)
	@(vif.drv_cb);
	forever
		begin
			seq_item_port.get_next_item(req);
			send_to_dut(req);
			seq_item_port.item_done();
		end
endtask: run_phase 

task rx_driver::send_to_dut(rx_xtn xtn);

	wait(vif.drv_cb.rx_fifo_empty == 0)
	@(vif.drv_cb);
	vif.drv_cb.rd_uart <= xtn.rd_uart;
	@(vif.drv_cb);
	vif.drv_cb.rd_uart <= 1'b0;
	
	repeat(1)
		@(vif.drv_cb);
		
endtask: send_to_dut

/*---------------------- REPORT NO_OF TRANSACTIONS ---------------------------*/

function void rx_driver::report_phase(uvm_phase phase);
	//`uvm_info("Report",$sformatf("Number of Transactions : %0d", req.trans_id), UVM_LOW);
endfunction: report_phase