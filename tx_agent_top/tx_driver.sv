//---------------------------------------------------------------------------
// TX DRIVER CLASS [EXTENDS FROM UVM_DRIVER]
//---------------------------------------------------------------------------
class tx_driver extends uvm_driver #(tx_xtn);
	`uvm_component_utils(tx_driver)
	
	tx_config m_cfg;
	virtual txmt_if.DRV vif; 
	
	
	// METHODS
	extern function new(string name = "tx_driver", uvm_component parent);
	extern function void build_phase(uvm_phase phase);
	extern function void connect_phase(uvm_phase phase);
	extern task run_phase(uvm_phase phase);
	extern task send_to_dut(tx_xtn xtn);
	extern function void report_phase(uvm_phase phase);
endclass: tx_driver

function tx_driver::new(string name = "tx_driver", uvm_component parent);
	super.new(name, parent);
endfunction: new

function void tx_driver::build_phase(uvm_phase phase);
	if(!uvm_config_db #(tx_config)::get(this,"","tx_config",m_cfg))
		`uvm_fatal("CONFIG","cannot get() m_cfg from uvm_config_db. Have you set() it?")
endfunction: build_phase

function void tx_driver::connect_phase(uvm_phase phase);
	vif = m_cfg.vif;
endfunction: connect_phase


task tx_driver::run_phase(uvm_phase phase);
	@(vif.drv_cb);
	vif.drv_cb.reset <= 1'b0;
	@(vif.drv_cb);
	vif.drv_cb.reset <= 1'b1;
	forever
		begin
			seq_item_port.get_next_item(req);
			send_to_dut(req);
			seq_item_port.item_done();
		end
endtask: run_phase 

task tx_driver::send_to_dut(tx_xtn xtn);
	
	wait(vif.drv_cb.tx_fifo_full == 0)
	@(vif.drv_cb);
	vif.drv_cb.wr_uart <= xtn.wr_uart;
	vif.drv_cb.w_data  <= xtn.w_data;
	@(vif.drv_cb);
	vif.drv_cb.wr_uart <= 1'b0;
	$display("@%0t: printing tx_xtn", $time);
	xtn.print();
	repeat(1)
		@(vif.drv_cb);
		
endtask: send_to_dut

/*---------------------- REPORT NO_OF TRANSACTIONS ---------------------------*/

function void tx_driver::report_phase(uvm_phase phase);
	`uvm_info("REPORT",$sformatf("No of Transactions: %0d", req.trans_id), UVM_LOW)
endfunction: report_phase