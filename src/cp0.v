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
)


endmodule
