`include "define.v"
module select_pc(
    input  wire [31:0] fetch_i_pre_pc,
    input  wire [31:0] execute_next_pc_i,
    input wire execute_addr_fix_i,
    input wire execute_branch_fix_i,
    input wire predict_taken,
    input wire btb_hit,
    input wire [31:0] btb_pre_pc,
	input wire execute_branch_jump_i,
    output wire [31:0] select_pc_o_pc
);
wire fix = execute_addr_fix_i | execute_branch_fix_i;
assign select_pc_o_pc =  fix ? execute_next_pc_i :
                         (predict_taken & btb_hit) ? btb_pre_pc : fetch_i_pre_pc;
                         
endmodule