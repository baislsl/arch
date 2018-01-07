module cmu (
	output reg stall,
	input wire rst,
	input wire cs,
	input wire clk,
	input wire we,
	input wire [31:0] addr,
	input wire [31:0] din,
	output reg [31:0] dout
    );

	parameter
		S_IDLE = 0,
		S_BACK = 1,
		S_BACK_WAIT = 2,
		S_FILL = 3,
		S_FILL_WAIT = 4;

	reg cache_store = 0;
	reg cache_edit = 0;
	reg cache_invalid = 0;
	wire cache_hit;
	wire [31:0] cache_dout;
	wire cache_valid;
	wire cache_dirty;
	wire [21:0] cache_tag;
	reg [31:0] cache_addr;
	reg [31:0] cache_din;

	cache CACHE (
		.clk(clk),
		.rst(rst),
		.addr(addr),
		.store(cache_store),
		.edit(cache_edit),
		.invalid(cache_invalid),
		.din(cache_din),
		.hit(cache_hit),
		.dout(cache_dout),
		.valid(cache_valid),
		.dirty(cache_dirty),
		.tag(cache_tag)
	);

	wire ram_stall;
	reg ram_rst;
	reg ram_cs;
	reg ram_we;
	reg [31:0] ram_addr;
	reg [31:0] ram_din;
	wire [31:0] ram_dout;
	wire ram_ack;

	data_ram RAM (
		.ram_stall(ram_stall),
		.rst(ram_rst),
		.cs(ram_cs),
		.clk(clk),
		.we(ram_we),
		.addr(ram_addr),
		.din(ram_din),
		.dout(ram_dout),
		.ack(ram_ack)
	);

	reg [2:0] state = S_IDLE;
	reg [2:0] next_state = S_IDLE;

	wire en_r, en_w;
	assign en_r = cs && ~we;
	assign en_w = cs && we;

	always @(posedge clk) begin
		if (rst) begin
			state = S_IDLE;
			word_count = 0;
			cache_din = 32'b0;
			cache_addr = 32'b0;
			cache_store = 0;
			cache_edit = 0;
			cache_invalid = 0;
			ram_rst = 1;
			ram_cs = 0;
			ram_we = 0;
			ram_addr = 32'b0;
			ram_din = 32'b0;
			stall = 0;
		end else begin
			cache_store = 0;
			cache_edit = 0;
			cache_invalid = 0;
			ram_rst = 0;
			ram_cs = 0;
			ram_we = 0;
			cache_addr = din;
			state = next_state;
			word_count = next_word_count;
			case (state)
				S_IDLE: begin
					if (en_r || en_w) begin
						if (cache_hit) begin
							next_state = S_IDLE;
							if (en_r) begin
								dout = cache_dout;
							end
							if (en_w) begin
								cache_din = din;
								cache_edit = 1;
							end
						end else if (cache_valid && cache_dirty) begin
							next_state = S_BACK;
							ram_addr = {addr[31:4],4'b0};
							stall = 1;
						end else begin
							next_state = S_FILL;
							stall = 1;
						end
					end
				end
				S_BACK: begin
					if (ram_ack) begin
						next_word_count = word_count + 1'h1;
						ram_addr = cache_addr;
						ram_din = cache_dout;
						ram_cs = 1;
						ram_we = 1;
						if (word_count == 2'b11) begin
							next_state = S_BACK_WAIT;
						end else begin
							next_state = S_BACK;
							cache_addr += 4'b0100;
						end
					end else begin
						next_word_count = word_count;
					end
				end
				S_BACK_WAIT: begin
					next_word_count = 0;
					next_state = S_FILL;
				end
				S_FILL: begin
					if (ram_ack)
						next_word_count = word_count + 1'h1;
						cache_addr = ram_addr;
						cache_din = ram_dout;
						cache_store = 1;
						ram_cs = 1;
						ram_we = 0;
						if (word_count == 2'b11)
							next_state = S_FILL_WAIT;
						else
							next_state = S_FILL;
							ram_addr += 4'b0100;
					else
						next_word_count = word_count;
				end
				S_FILL_WAIT: begin
					next_word_count = 0;
					next_state <= S_IDLE;
					stall = 0;
				end
			endcase
		end
	end

endmodule