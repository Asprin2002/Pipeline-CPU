`include "define.v"
//****************************************VSCODE PLUG-IN**********************************//
//----------------------------------------------------------------------------------------
// IDE :                   VSCODE     
// VSCODE plug-in version: Verilog-Hdl-Format-3.5.20250220
// VSCODE plug-in author : Jiang Percy
//----------------------------------------------------------------------------------------
//****************************************Copyright (c)***********************************//
// Copyright(C)            Please Write Company name
// All rights reserved     
// File name:              
// Last modified Date:     2025/02/22 02:15:11
// Last Version:           V1.0
// Descriptions:           
//----------------------------------------------------------------------------------------
// Created by:             Please Write You Name 
// Created date:           2025/02/22 02:15:11
// mail      :             Please Write mail 
// Version:                V1.0
// TEXT NAME:              regM.v
// PATH:                   ~/pipeline-cpu/IP/mycpu/regM.v
// Descriptions:           
//                         
//----------------------------------------------------------------------------------------
//****************************************************************************************//

module regM(
    input                               clk,
    input                               rst,
    //execute阶段传来的信号
    input wire [31:0]   execute_i_valE,
    input wire [31:0]   execute_mem_addr_i,
    //regE寄存器直接传来的信号
    input wire          regE_i_wb_reg_wen,
    input wire [4:0]    regE_i_wb_rd,
    input wire [1:0]    regE_i_wb_valD_sel,

    input wire[ 9:0]  regE_opcode_info_i,
	input wire[ 9:0]  regE_alu_info_i,
	input wire[ 5:0]  regE_branch_info_i,
	input wire[ 7:0]  regE_load_store_info_i,
	input wire[ 5:0]  regE_csr_info_i,
    input wire execute_branch_jump_i,

    
    input wire [31:0]   regE_i_valB,
    //commit for simulator
    input wire  [31:0]  regE_i_instr,
    input wire  [31:0]  regE_i_pc,
    input wire          regE_i_commit,
    input wire [31:0] execute_i_pre_pc, // already correct pc value;

    output reg [31:0]   regM_o_valE,
    output reg [31:0]   regM_mem_addr_o,

    output reg [31:0]   regM_o_valB,
    output reg          regM_o_wb_reg_wen,
    output reg [4:0]    regM_o_wb_rd,
    output wire [1:0]    regM_o_wb_valD_sel,

    output reg[ 9:0]  regM_opcode_info_o,
	output reg[ 9:0]  regM_alu_info_o,
	output reg[ 5:0]  regM_branch_info_o,
	output reg[ 7:0]  regM_load_store_info_o,
	output reg[ 5:0]  regM_csr_info_o,
    output reg regM_branch_jump_o,

    //commit for simulator
    output reg [31:0]   regM_o_instr,
    output reg [31:0]   regM_o_pc,
    output reg          regM_o_commit,
    output reg [31:0]   regM_o_pre_pc           
);


always @(posedge clk) begin
    if(rst) begin
        regM_o_valE         <= 32'd0;
        regM_mem_addr_o     <= 32'd0;
        regM_o_wb_reg_wen   <= `reg_wen_no_w;
        regM_o_wb_rd        <= 5'd0;
        regM_o_valB         <= 32'd0;
        regM_o_wb_valD_sel  <= `wb_valD_sel_valE;

        regM_opcode_info_o <= 10'd0;
	    regM_alu_info_o <= 10'd0;
	    regM_branch_info_o <= 6'd0;
	    regM_load_store_info_o <= 8'd0;
	    regM_csr_info_o <= 6'd0;
        regM_branch_jump_o <= 1'd0;
        //commit for simulator
        regM_o_pc           <= 32'd0;
        regM_o_commit       <= 1'd0;
        regM_o_pre_pc       <= 32'd0;
    end
    else begin
        regM_o_valE         <= execute_i_valE;
        regM_mem_addr_o     <= execute_mem_addr_i;
        regM_o_wb_reg_wen   <= regE_i_wb_reg_wen;
        regM_o_wb_rd        <= regE_i_wb_rd;
        regM_o_wb_valD_sel  <= regE_i_wb_valD_sel;
        regM_o_valB         <= regE_i_valB;

        regM_opcode_info_o <= regE_opcode_info_i;
	    regM_alu_info_o <= regE_alu_info_i;
	    regM_branch_info_o <= regE_branch_info_i;
	    regM_load_store_info_o <= regE_load_store_info_i;
	    regM_csr_info_o <= regE_csr_info_i;
        regM_branch_jump_o <= execute_branch_jump_i;
        //commit for simulator
        regM_o_instr        <= regE_i_instr;
        regM_o_pc           <= regE_i_pc;
        regM_o_commit       <= regE_i_commit;
        regM_o_pre_pc       <= execute_i_pre_pc;
    end
end
                                                                   
endmodule