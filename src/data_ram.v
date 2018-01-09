module data_ram (
	output wire ram_stall,
	input wire rst,
	input wire cs,

	input wire clk,
	input wire we,
	input wire [31:0] addr,
	input wire [31:0] din,
	output reg [31:0] dout,
	output wire ack
	);

	parameter
		ADDR_WIDTH = 5;

	reg [31:0] data [0:(1<<ADDR_WIDTH)-1];
    reg [1:0]counter;
    reg [31:0] addr_previous;

	initial	begin
		$readmemh("data_mem.hex", data);
	end

	always @(negedge clk) begin
		if (we && addr[31:ADDR_WIDTH]==0)
			data[addr[ADDR_WIDTH-1:0]] <= din;
	end

	reg [31:0] out;
	always @(negedge clk) begin
        if (rst) begin
            counter=0;
        end else begin
            if (addr_previous==addr) begin
                counter = counter + 1;
                if (counter==3) begin
                    if (we && addr[31:ADDR_WIDTH]==0)
                        data[addr[ADDR_WIDTH-1:0]] = din;
                    out = data[addr[ADDR_WIDTH-1:0]];
                end
            end else begin
                counter=0;
            end
            addr_previous=addr;
        end
	end

	assign ack = counter == 3 & addr_previous == addr; 
    assign ram_stall = cs & ~ack;

	always @(*) begin
		if (addr[31:ADDR_WIDTH] != 0)
			dout = 32'h0;
		else
			dout = out;
	end

endmodule
