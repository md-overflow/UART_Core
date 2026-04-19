//---------------------------------------------------------------------------
// SCOREBOARD CLASS [EXTENDS FROM UVM_SCOREBOARD]
//---------------------------------------------------------------------------
class uart_sb extends uvm_scoreboard;
	`uvm_component_utils(uart_sb)
	
	uvm_tlm_analysis_fifo #(tx_xtn) tx_fifo;
	uvm_tlm_analysis_fifo #(rx_xtn) rx_fifo;
	
	tx_xtn tx_data;
	rx_xtn rx_data;
	
	static int pass_count;
	static int fail_count;
	
	// METHODS
	extern function new(string name = "uart_sb", uvm_component parent);
	extern function void build_phase(uvm_phase phase);
	extern task run_phase(uvm_phase phase);
	extern task compare(tx_xtn t_xtn, rx_xtn r_xtn);
	extern function void report_phase(uvm_phase phase);
	
endclass: uart_sb

function uart_sb::new(string name = "uart_sb", uvm_component parent);
	super.new(name, parent);
endfunction: new

function void uart_sb::build_phase(uvm_phase phase);
	tx_fifo = new("tx_fifo", this);
	rx_fifo = new("rx_fifo", this);
endfunction: build_phase

task uart_sb::run_phase(uvm_phase phase);
	forever
		begin
			fork
				begin
					tx_fifo.get(tx_data);
					//tx_data.print();
					//ahb_cg.sample();
				end
	
				begin
					rx_fifo.get(rx_data);
					//rx_data.print();
					//rx_data.sample();
				end
			join
			compare(tx_data, rx_data);
		end
endtask:run_phase

task uart_sb::compare(tx_xtn t_xtn, rx_xtn r_xtn);
	begin
		if(t_xtn.w_data == r_xtn.r_data)
			begin
				`uvm_info("SB","DATA COMPARISION SUCCESSFUL",UVM_LOW)
				`uvm_info("SB",$sformatf("DATA_TRANSMITTED = %0h, DATA_RECEIVED = %0h", t_xtn.w_data, r_xtn.r_data),UVM_LOW)
				pass_count++;
			end
		else
			begin
				`uvm_info("SB","DATA COMPARISION FAILED",UVM_LOW)
				`uvm_info("SB",$sformatf("DATA_TRANSMITTED = %0h, DATA_RECEIVED = %0h", t_xtn.w_data, r_xtn.r_data),UVM_LOW)
				fail_count++;
			end
	end
endtask: compare



/*---------------------- REPORT TRANSACTIONS COMPARED ---------------------------*/

function void uart_sb::report_phase(uvm_phase phase);
	`uvm_info("REPORT",$sformatf("Number of Successful Comparisons      = %0d", pass_count),UVM_LOW)
	`uvm_info("REPORT",$sformatf("Number of Unsuccessful Comparisons    = %0d", fail_count),UVM_LOW)
endfunction: report_phase