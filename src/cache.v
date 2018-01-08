module cache (
    input wire clk, // clock
    input wire rst, // reset
    input wire [ADDR_BITS-1:0] addr, // address
    input wire store, // set valid to 1 and reset dirty to 0
    input wire edit, // set dirty to 1
    input wire invalid, // reset valid to 0
    input wire [WORD_BITS-1:0] din, // data write in
    output wire hit, // hit or not
    output wire [WORD_BITS-1:0] dout, // data read out
    output wire valid, // valid bit
    output wire dirty, // dirty bit
    output wire [TAG_BITS-1:0] tag // tag bits
);

	parameter
        WORD_BITS = 32,
	    ADDR_BITS = 32,
        TAG_BITS = 22,
        WORD_BYTES_WIDTH = 2,
        LINE_WORDS_WIDTH = 2,
        LINE_NUM = 64,
        LINE_INDEX_WIDTH = 6;
    
    reg [LINE_NUM-1:0] inner_valid;
    reg [LINE_NUM-1:0] inner_dirty;
    reg [TAG_BITS-1:0] inner_tag [0:LINE_NUM-1];
    reg [WORD_BITS-1:0] inner_data [0:LINE_NUM*LINE_WORDS_WIDTH-1];
	 
	 initial begin
		inner_valid = 0;
		inner_dirty = 0;
	 end

    assign hit = (addr[ADDR_BITS-1:ADDR_BITS-TAG_BITS]==inner_tag[addr[ADDR_BITS-TAG_BITS-1:LINE_WORDS_WIDTH+WORD_BYTES_WIDTH]]) && valid;

    assign dout = inner_data[addr[ADDR_BITS-TAG_BITS-1:WORD_BYTES_WIDTH]];
    assign valid = inner_valid[addr[ADDR_BITS-TAG_BITS-1:LINE_WORDS_WIDTH+WORD_BYTES_WIDTH]];
    assign dirty = inner_dirty[addr[ADDR_BITS-TAG_BITS-1:LINE_WORDS_WIDTH+WORD_BYTES_WIDTH]];
    assign tag = inner_tag[addr[ADDR_BITS-TAG_BITS-1:LINE_WORDS_WIDTH+WORD_BYTES_WIDTH]];

    always @(posedge clk) begin
        
        if (rst) begin
            inner_valid <= 0;
        end else begin
            if (store || edit) begin
                inner_data[addr[ADDR_BITS-TAG_BITS-1:WORD_BYTES_WIDTH]] <= din;
            end
            if (invalid) begin
                inner_valid[addr[ADDR_BITS-TAG_BITS-1:LINE_WORDS_WIDTH+WORD_BYTES_WIDTH]] <= 0;
                inner_dirty[addr[ADDR_BITS-TAG_BITS-1:LINE_WORDS_WIDTH+WORD_BYTES_WIDTH]] <= 1; //TODO not sure
            end else if(store) begin
                inner_valid[addr[ADDR_BITS-TAG_BITS-1:LINE_WORDS_WIDTH+WORD_BYTES_WIDTH]] <= 1;
                inner_dirty[addr[ADDR_BITS-TAG_BITS-1:LINE_WORDS_WIDTH+WORD_BYTES_WIDTH]] <= 0;
                inner_tag[addr[ADDR_BITS-TAG_BITS-1:LINE_WORDS_WIDTH+WORD_BYTES_WIDTH]] <= addr[ADDR_BITS-1:ADDR_BITS-TAG_BITS];
            end else if (edit) begin
                inner_dirty[addr[ADDR_BITS-TAG_BITS-1:LINE_WORDS_WIDTH+WORD_BYTES_WIDTH]] <= 1;
                //inner_tag[addr[ADDR_BITS-TAG_BITS-1:LINE_WORDS_WIDTH+WORD_BYTES_WIDTH]] <= //TODO seems no need to set tag?
            end
        end

    end

endmodule