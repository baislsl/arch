`include "define.vh"


/**
 * MIPS 5-stage pipeline CPU Core, including data path and co-processors.
 * Author: Zhao, Hongyu  <power_zhy@foxmail.com>
 */
module mips_core (
	input wire clk,  // main clock
	input wire rst,  // synchronous reset
	// debug
	`ifdef DEBUG
	input wire debug_en,  // debug enable
	input wire debug_step,  // debug step clock
	input wire [6:0] debug_addr,  // debug address
	output wire [31:0] debug_data,  // debug data
	`endif
	// instruction interfaces
	output wire inst_ren,  // instruction read enable signal
	output wire [31:0] inst_addr,  // address of instruction needed
	input wire [31:0] inst_data,  // instruction fetched
	// memory interfaces
	output wire mem_ren,  // memory read enable signal
	output wire mem_wen,  // memory write enable signal
	output wire [31:0] mem_addr,  // address of memory
	output wire [31:0] mem_dout,  // data writing to memory
	input wire [31:0] mem_din,  // data read from memory
    input wire interrupter
	);

	// control signals
	wire [31:0] inst_data_ctrl;

	wire [2:0] pc_src_ctrl;
	wire imm_ext_ctrl;
	wire [1:0] exe_a_src_ctrl, exe_b_src_ctrl;
	wire [3:0] exe_alu_oper_ctrl;
	wire mem_ren_ctrl;
	wire mem_wen_ctrl;
	wire [1:0] wb_addr_src_ctrl;
	wire wb_data_src_ctrl;
	wire wb_wen_ctrl;

	wire [4:0] regw_addr_exe, regw_addr_mem;
	wire wb_wen_exe, wb_wen_mem;

	wire if_rst, if_en, if_valid;
	wire id_rst, id_en, id_valid;
	wire exe_rst, exe_en, exe_valid;
	wire mem_rst, mem_en, mem_valid;
	wire wb_rst, wb_en, wb_valid;

	wire [1:0]fwd_a_ctrl;
	wire [1:0]fwd_b_ctrl;

    wire [4:0] regw_addr_wb;
    wire [4:0] addr_rs_exe;
    wire [4:0] addr_rt_exe;
   wire mem_ren_mem;
   wire wb_wen_wb;

   wire a_b_equal;
   wire fwd_m;

   wire alu_sign;

   wire [1:0] oper;
   wire [4:0] addr_r;
   wire [31:0] data_r;
   wire [4:0] addr_w;
   wire [31:0]	data_w;
   wire ir_en;
   wire ir_in;
   wire [31:0] ret_addr;
   wire jump_en;
   wire [31:0] jump_addr;

	// controller
	controller CONTROLLER (
		.clk(clk),
		.rst(rst),
		`ifdef DEBUG
		.debug_en(debug_en),
		.debug_step(debug_step),
		`endif
		.fwd_a_ctrl(fwd_a_ctrl),
		.fwd_b_ctrl(fwd_b_ctrl),
		.inst(inst_data_ctrl),
		.regw_addr_exe(regw_addr_exe),
		.wb_wen_exe(wb_wen_exe),
		.regw_addr_mem(regw_addr_mem),
		.pc_src(pc_src_ctrl),
		.imm_ext(imm_ext_ctrl),
		.exe_a_src(exe_a_src_ctrl),
		.exe_b_src(exe_b_src_ctrl),
		.exe_alu_oper(exe_alu_oper_ctrl),
		.mem_ren(mem_ren_ctrl),
		.mem_wen(mem_wen_ctrl),
		.wb_addr_src(wb_addr_src_ctrl),
		.wb_data_src(wb_data_src_ctrl),
		.wb_wen(wb_wen_ctrl),
		.unrecognized(),
		.if_rst(if_rst),
		.if_en(if_en),
		.if_valid(if_valid),
		.id_rst(id_rst),
		.id_en(id_en),
		.id_valid(id_valid),
		.exe_rst(exe_rst),
		.exe_en(exe_en),
		.exe_valid(exe_valid),
		.mem_rst(mem_rst),
		.mem_en(mem_en),
		.mem_valid(mem_valid),
		.wb_rst(wb_rst),
		.wb_en(wb_en),
		.wb_valid(wb_valid),
        .regw_addr_wb(regw_addr_wb),
        .addr_rs_exe(addr_rs_exe),
        .addr_rt_exe(addr_rt_exe),
        .mem_ren_mem(mem_ren_mem),
        .wb_wen_wb(wb_wen_wb),
        .wb_wen_mem(wb_wen_mem),
        .a_b_equal(a_b_equal),
        .fwd_m(fwd_m),
        .sign(alu_sign),

		// interrupt
		.oper(oper),
		.jump_en(jump_en)
	);

	// data path
	datapath DATAPATH (
		.clk(clk),
		`ifdef DEBUG
		.debug_addr(debug_addr[5:0]),
		.debug_data(debug_data),
		`endif
		.fwd_a_ctrl(fwd_a_ctrl),
		.fwd_b_ctrl(fwd_b_ctrl),
		.inst_data_id(inst_data_ctrl),
		.regw_addr_exe(regw_addr_exe),
		.wb_wen_exe(wb_wen_exe),
		.regw_addr_mem(regw_addr_mem),
		.pc_src_ctrl(pc_src_ctrl),
		.imm_ext_ctrl(imm_ext_ctrl),
		.exe_a_src_ctrl(exe_a_src_ctrl),
		.exe_b_src_ctrl(exe_b_src_ctrl),
		.exe_alu_oper_ctrl(exe_alu_oper_ctrl),
		.mem_ren_ctrl(mem_ren_ctrl),
		.mem_wen_ctrl(mem_wen_ctrl),
		.wb_addr_src_ctrl(wb_addr_src_ctrl),
		.wb_data_src_ctrl(wb_data_src_ctrl),
		.wb_wen_ctrl(wb_wen_ctrl),
		.if_rst(if_rst),
		.if_en(if_en),
		.if_valid(if_valid),
		.inst_ren(inst_ren),
		.inst_addr(inst_addr),
		.inst_data(inst_data),
		.id_rst(id_rst),
		.id_en(id_en),
		.id_valid(id_valid),
		.exe_rst(exe_rst),
		.exe_en(exe_en),
		.exe_valid(exe_valid),
		.mem_rst(mem_rst),
		.mem_en(mem_en),
		.mem_valid(mem_valid),
		.mem_ren(mem_ren),
		.mem_wen(mem_wen),
		.mem_addr(mem_addr),
		.mem_dout(mem_dout),
		.mem_din(mem_din),
		.wb_rst(wb_rst),
		.wb_en(wb_en),
		.wb_valid(wb_valid),
        .regw_addr_wb(regw_addr_wb),
        .addr_rs_exe(addr_rs_exe),
        .addr_rt_exe(addr_rt_exe),
        .mem_ren_mem(mem_ren_mem),
        .wb_wen_wb(wb_wen_wb),
        .wb_wen_mem(wb_wen_mem),
        .a_b_equal(a_b_equal),
        .fwd_m(fwd_m),
        .alu_sign(alu_sign),

		// interrupt
		.oper(oper),
		.addr_r(addr_r),
		.data_r(data_r),
		.addr_w(addr_w),
		.data_w(data_w),
		.ir_en(ir_en),
		.ir_in(interrupter),
		.ret_addr(ret_addr),
		.jump_en(jump_en),
		.jump_addr(jump_addr)


	);


    cp0 CP0 (
		.clk(clk), // main clock
		`ifdef DEBUG
		.debug_addr(debug_addr), // debug address
		.debug_data(debug_data), // debug data
		`endif
		// operations (read in ID stage and write in EXE stage)
		.oper(oper), // CP0 operation type
		.addr_r(addr_r), // read address
		.data_r(data_r), // read data
		.addr_w(addr_w), // write address
		.data_w(data_w), // write data
		// exceptions (check exceptions in MEM stage)
		.rst(rst), // synchronous reset
		.ir_en(ir_en), // interrupt enable
		.ir_in(interrupter), // external interrupt input
		.ret_addr(ret_addr), // target instruction address to store when interrupt occurred
		.jump_en(jump_en), // force jump enable signal when interrupt authorised or ERET occurred
		.jump_addr(jump_addr) // target instruction address to jump to
    );

endmodule
