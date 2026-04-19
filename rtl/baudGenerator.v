`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Md Mudassir Ahmed
// 
// Create Date:    12/15/2024 
// Design Name: 
// Module Name: mod_m_counter 
// Project Name: UART IP Core
// Description: UART Baud Rate Generator
//////////////////////////////////////////////////////////////////////////////////

module baudGenerator #(parameter CLK_FREQ  = 25000000,
                      			 BAUD_RATE = 19200,
                       			 WIDTH	   = 8) (clk, reset, max_tick);

    parameter DVSR = CLK_FREQ/(16*BAUD_RATE);	// baud rate divisor
											    // DVSR = 25MHz/(16*baud_rate)
			  
	input clk, reset;
	output max_tick;
	
  reg [WIDTH-1:0] count;
	
  always @(posedge clk, negedge reset)
		begin
			if(!reset)
				count <= {WIDTH{1'b0}};
          	else if(count == DVSR)
          		count <= {WIDTH{1'b0}};
          	else
              count <= count + 1;
		end
	
	assign max_tick = (count == DVSR)? 1'b1 : 1'b0; 
	
endmodule