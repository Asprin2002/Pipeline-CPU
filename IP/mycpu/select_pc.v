`include "define.v"
module select_pc(
    input  wire [31:0] fetch_i_pre_pc,
    input  wire [31:0] execute_next_pc_i,
	input wire execute_branch_jump_i,
    output wire [31:0] select_pc_o_pc
);

assign select_pc_o_pc =  execute_branch_jump_i ? execute_next_pc_i : fetch_i_pre_pc;
endmodule