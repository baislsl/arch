`include "define.vh"

module cp0 (
    input wire clk, // main clock
    `ifdef DEBUG
    input wire [4:0] debug_addr, // debug address
    output reg [31:0] debug_data, // debug data
    `endif
    // operations (read in ID stage and write in EXE stage)
    input wire [1:0] oper, // CP0 operation type
    input wire [4:0] addr_r, // read address
    output reg [31:0] data_r, // read data
    input wire [4:0] addr_w, // write address
    input wire [31:0] data_w, // write data
    // exceptions (check exceptions in MEM stage)
    input wire rst, // synchronous reset
    input wire ir_en, // interrupt enable
    input wire ir_in, // external interrupt input
    input wire [31:0] ret_addr, // target instruction address to store when interrupt occurred
    output reg jump_en, // force jump enable signal when interrupt authorised or ERET occurred
    output reg [31:0] jump_addr // target instruction address to jump to
    );
	`include "mips_define.vh"

    reg [31:0] regs[31:0];

    // interrupt determination
    wire ir;
    reg ir_wait = 0, ir_valid = 1;
    reg eret = 0;
    always @(posedge clk) begin
        if (rst)
            ir_wait <= 0;
        else if (ir_in)
            ir_wait <= 1;
        else if (eret)
            ir_wait <= 0;
    end

    always @(posedge clk) begin
        if (rst)
            ir_valid <= 1;
        else if (eret)
            ir_valid <= 1;
        else if (ir)
            ir_valid <= 0; // prevent exception reenter
    end

    assign ir = ir_en & ir_wait & ir_valid;

    // // Exception Handler Base Register
    // always @(posedge clk) begin
    //
    // end
    //
    // // Exception Program Counter Register
    // always @(posedge clk) begin
    //     //……
    // end

    always @(posedge clk) begin
        data_r <= regs[addr_r];
    end

    // jump determination
    always @(*) begin	// TODO: seems to has bugs
        if (oper == EXE_CP0_ERET) begin //eret
            jump_addr <= regs[CP0_EPCR];
            jump_en <= 1;
        end else if (oper == EXE_CP_STORE) begin
		      regs[addr_w] <= data_w;
		  end else if (ir) begin //external interrupt
            jump_addr <= regs[CP0_EHBR];
            regs[CP0_EPCR] <= ret_addr;
            jump_en <= 1;
        end else begin
            jump_en <= 0;
            jump_addr <= 32'b0;
        end
    end

endmodule
