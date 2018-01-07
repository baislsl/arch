module cmu (
	output wire stall,//TODO
	input wire rst,
	input wire cs,
	input wire clk,
	input wire we,
	input wire [31:0] addr,
	input wire [31:0] din,
	output reg [31:0] dout
    );

	reg cache_store = 0;
	reg cache_edit = 0;
	reg cache_invalid = 0;
	wire cache_hit;
	wire [31:0] cache_dout;
	wire cache_valid;
	wire cache_dirty;
	wire [21:0] cache_tag;

	cache CACHE (
		.clk(clk),
		.rst(rst),
		.addr(addr),
		.store(cache_store),
		.edit(cache_edit),
		.invalid(cache_invalid),
		.din(din),
		.hit(cache_hit),
		.dout(cache_dout),
		.valid(cache_valid),
		.dirty(cache_dirty),
		.tag(cache_tag)
	);

	wire ram_stall;
	wire [31:0] ram_dout;

	data_ram RAM (
		.ram_stall(ram_stall),
		.rst(rst),
		.cs(cs),
		.clk(clk),
		.we(we),
		.addr(addr),
		.din(din),
		.dout(ram_dout)
	);


endmodule