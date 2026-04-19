`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Md Mudassir Ahmed
// 
// Design Name: FIFO Buffer
// Module Name:    fifo_buf 
// Project Name: UART Core
// Description: fifo to increase the buffer space during transmission and reception
////////////////////////////////////////////////////////////////////////////////////

module fifo_buf #(parameter 	WIDTH = 8,
								DEPTH = 8) (clk, reset, wr_en, rd_en, w_data, r_data, full, empty, not_empty);
	
	
	input clk, reset;
	input wr_en, rd_en;
	input [WIDTH-1:0] w_data;
	output reg [WIDTH-1:0] r_data;
	output full, empty, not_empty;
	
	// Declare Memory
	reg [WIDTH-1:0] mem [DEPTH-1:0]; 
	
	// Declare internal signal
	reg [$clog2(DEPTH):0] rd_ptr, wr_ptr; 		// read pointer & write pointer
	integer i;
	
	// Read Logic
	always @(posedge clk, negedge reset)
		begin
			if(!reset)
				begin
					r_data <= 0;
					//rd_ptr <= 0;
				end
			else if(rd_en && (!empty)) 
				begin
					r_data <= mem[rd_ptr];
					//rd_ptr <= rd_ptr + 1;
				end
		end
	
	// Write Logic
	always @(posedge clk, negedge reset)
		begin
			if(!reset)
				begin
					//wr_ptr <= 0;
					for(i=0; i<8; i=i+1)
						mem[i] <= 0;
				end
			else if(wr_en && (!full)) 
				begin
					mem[wr_ptr] <= w_data;
					//wr_ptr <= wr_ptr + 1;
				end
		end
		
	// Pointer Logic
	
	always @(posedge clk, negedge reset)
		begin
			if(!reset)
				begin
					rd_ptr <= 0;
					wr_ptr <= 0;
				end
			else
				begin
					if(rd_en && (!empty))
						rd_ptr <= rd_ptr + 1;
					if(wr_en && (!full))
						wr_ptr <= wr_ptr + 1;
				end
		end
	
	
	// Assign outputs full and empty
	assign full  = ((wr_ptr[$clog2(DEPTH)] != rd_ptr[$clog2(DEPTH)]) &&(wr_ptr[$clog2(DEPTH)-1:0] == rd_ptr[$clog2(DEPTH)-1:0]))? 1'b1 : 1'b0;
	assign empty = (wr_ptr == rd_ptr)? 1'b1 : 1'b0;
	assign not_empty = ~empty;
endmodule
