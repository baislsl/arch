`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   14:05:08 01/08/2018
// Design Name:   cache
// Module Name:   /media/baislsl/others/ISE3/exp09/src/sim_cache.v
// Project Name:  exp09
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: cache
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module sim_cache;

	// Inputs
	reg clk;
	reg rst;
	reg [31:0] addr;
	reg store;
	reg edit;
	reg invalid;
	reg [31:0] din;

	// Outputs
	wire hit;
	wire [31:0] dout;
	wire valid;
	wire dirty;
	wire [21:0] tag;

	// Instantiate the Unit Under Test (UUT)
	cache uut (
		.clk(clk), 
		.rst(rst), 
		.addr(addr), 
		.store(store), 
		.edit(edit), 
		.invalid(invalid), 
		.din(din), 
		.hit(hit), 
		.dout(dout), 
		.valid(valid), 
		.dirty(dirty), 
		.tag(tag)
	);

	initial begin
		// Initialize Inputs
		clk = 0;
		rst = 0;
		addr = 0;
		store = 0;
		edit = 0;
		invalid = 0;
		din = 0;
		
		#210 store = 1; din = 32'h1111_1111; addr = 32'h0000_0000;
		#20 addr = 32'h0000_0004;
		#20 addr = 32'h0000_00A8;
		#20 addr = 32'h0000_001C;
		#20 store = 0; addr = 32'h0000_00B4; din = 0;
		#100 edit = 1; din = 32'h2222_2222; addr = 32'h0000_0008;
		#100 edit = 0; din = 0; addr = 0;
        
		// Add stimulus here
	end
	
   initial forever #10 clk = ~clk;

endmodule

