`include "define.v"
//****************************************VSCODE PLUG-IN**********************************//
//----------------------------------------------------------------------------------------
// IDE :                   VSCODE     
// VSCODE plug-in version: Verilog-Hdl-Format-3.3.20250120
// VSCODE plug-in author : Jiang Percy
//----------------------------------------------------------------------------------------
//****************************************Copyright (c)***********************************//
// Copyright(C)            Please Write Company name
// All rights reserved     
// File name:              
// Last modified Date:     2025/02/14 22:34:19
// Last Version:           V1.0
// Descriptions:           
//----------------------------------------------------------------------------------------
// Created by:             Please Write You Name 
// Created date:           
// mail      :             Please Write mail 
// Version:                V1.0
// TEXT NAME:              execute.v
// PATH:                   ~/single-cycle-cpu/IP/mycpu/execute.v
// Descriptions:           
//                         
//----------------------------------------------------------------------------------------
//****************************************************************************************//

module execute
#(WIDTH = 32, REG_WIDTH=5)
(	
	input wire clk,
	input wire rst,

	input wire[9 : 0]  regE_opcode_info_i,
	input wire[9 : 0]  regE_alu_info_i,
	input wire[5 : 0]  regE_branch_info_i,
	input wire[7 : 0]  regE_load_store_info_i,

	input wire[31:0]   regE_i_pre_pc,
    
    input wire [31:0] 	regE_i_valA,
    input wire [31:0] 	regE_i_valB,
    input wire [31:0] 	regE_i_imm ,
	input wire [31:0]	regE_i_pc,
	input wire  regE_i_need_jump,

	input wire [31:0] regE_btb_addr_i,
	input wire regE_predict_taken_i,
	input wire regE_isBranch_i,
	input wire regE_hit,

    output wire[WIDTH-1 : 0]     execute_o_valE,
	output wire[WIDTH-1 : 0]     execute_mem_addr_o,
	output wire[31:0] execute_next_pc_o,
	output wire execute_branch_jump_o,
	output wire execute_o_need_jump,
	output wire execute_addr_fix_o,
	output wire execute_branch_fix_o,
	output wire execute_isBranch_o,
	output wire [31:0] execute_pc_o,
	output wire [31:0] fault_rate_o


);
reg [31:0] total_branch;
reg [31:0] branch_fault;

always @(posedge clk) begin
	if(rst) begin
		total_branch <= 0;
		branch_fault <= 0;
	end
	else if (regE_isBranch_i) begin
		total_branch <= total_branch + 1;
		branch_fault <= branch_fault + {31'b0, execute_branch_fix_o};
	end
end

assign fault_rate_o = (branch_fault * 100) / total_branch;

assign execute_pc_o = regE_i_pc;
assign execute_isBranch_o = | regE_branch_info_i;
wire[31:0] execute_next_pc;
assign execute_addr_fix_o = ((regE_hit && execute_next_pc != regE_btb_addr_i) || (!regE_hit && regE_isBranch_i)); 
assign execute_next_pc_o = execute_next_pc;
assign execute_branch_fix_o = (regE_i_need_jump != regE_predict_taken_i);
assign execute_o_need_jump = regE_i_need_jump;
alu alu_module(
	.opcode_info_i     (regE_opcode_info_i    ),
	.alu_info_i        (regE_alu_info_i       ),
	.branch_info_i     (regE_branch_info_i    ),
	.load_store_info_i (regE_load_store_info_i),

	.pc_i              (regE_i_pc              ),
	.rs1_data_i        (regE_i_valA),
	.rs2_data_i        (regE_i_valB),
	.imm_i             (regE_i_imm              ),
	
	.alu_result_o      (execute_o_valE ),
	.mem_addr_o        (execute_mem_addr_o   ),
	.alu_branch_jump_o (execute_branch_jump_o),
	.pc_next_o(execute_next_pc)
);

                                                                   
                                                                   
endmodule

