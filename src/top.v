`timescale 1ns / 1ps
module top (
	input wire clk,
	input wire rst,
	output reg [7:0] clk_count,
	output reg [7:0] inst_count,
	output reg [7:0] hit_count
	);

	// syntax error, TODO: 	
	// initial begin
	// 	clk_count = 0;
	// 	inst_count = 0;
	// 	hit_count = 0;
	
	// end
		// instruction
	reg [3:0] index = 0;
	wire valid;
	wire write;
	wire [31:0] addr;
	wire stall;
	always @(posedge clk) begin
		if (rst)
			index <= 0;
		else if (valid && ~stall)
			index <= index + 1'h1;
	end
	// ram
	wire mem_cs;
	wire mem_we;
	wire [31:0] mem_addr;
	wire [31:0] mem_din;
	wire [31:0] mem_dout;
	wire mem_ack;
	
	// counter
	reg stall_prev;
	
	always @(posedge clk) begin
		if (rst)
			stall_prev <= 1;
		else
			stall_prev <= stall;
	end
	
	always @(posedge clk) begin
		if (rst) begin
			clk_count <= 0;   // 时钟计数
			inst_count <= 0;  // 指令计数
			hit_count <= 0;   // 命中计数
		end
		else if (valid) begin
			clk_count <= clk_count + 1'h1;
			inst_count <= index + 1'h1;
			if (~stall_prev && ~stall)
				hit_count <= hit_count + 1'h1;
		end
	end
	
	inst INST (
		.clk(clk),
		.rst(rst),
		.index(index),
		.valid(valid),
		.write(write),
		.addr(addr)
	);
	
 	data_ram #(
		.ADDR_WIDTH(5),
		.CLK_DELAY(3)
		) RAM (
		.clk(clk),
		.rst(rst),
		.addr({26'b0, mem_addr[5:0]}),
		.cs(mem_cs),
		.we(mem_we),
		.din(mem_din),
		.dout(mem_dout),
		.ram_stall(),
		.ack(mem_ack)
		);
	cmu CMU (
		.stall(stall),
		.rst(rst),
		.clk(clk),
		.we(write),
		.addr(addr),
		.dout(),
		.din({16'h5678, clk_count, inst_count}),
		.ram_stall(), // TODO:
		.ram_rst(),
		.ram_cs(mem_cs),
		.ram_we(mem_we),
		.ram_addr(mem_addr),
		.ram_dout(mem_dout),
		.ram_din(mem_din),
		.ram_ack(mem_ack)
	);

endmodule
