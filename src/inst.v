`timescale 1ns / 1ps
module inst(
	input wire clk,
	input wire rst,
	input wire [3:0]index, // instruction index
	output wire valid , // stop running if valid is 0
	output wire write, // write enable signal for cache
	output wire[31:0] addr //address for cache
);
	reg [33:0] data [0:7];
	initial begin 
		data[0] = 34'h2_0000_0004;
		data[1] = 34'h3_0000_0018;
		data[2] = 34'h2_0000_0008;
		data[3] = 34'h3_0000_0014;
		data[4] = 34'h2_1000_0004;
		data[5] = 34'h3_1000_0018;
		data[6] = 34'h3_1000_0008;
		data[7] = 34'h0;
	end 
	
	assign 
		valid = data[index][33],
		write = data[index][32],
		addr = data[index][31:0];
		endmodule
