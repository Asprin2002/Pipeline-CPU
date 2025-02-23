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
// Last modified Date:     2025/02/22 03:27:25
// Last Version:           V1.0
// Descriptions:           
//----------------------------------------------------------------------------------------
// Created by:             Please Write You Name 
// Created date:           
// mail      :             Please Write mail 
// Version:                V1.0
// TEXT NAME:              regW.v
// PATH:                   ~/pipeline-cpu/IP/mycpu/regW.v
// Descriptions:           
//                         
//----------------------------------------------------------------------------------------
//****************************************************************************************//

module regW(
    input                               clk                        ,
    input                               rst,

    input wire          regM_i_wb_reg_wen,
    input wire [4:0]    regM_i_wb_rd,
    input wire [1:0]    regM_i_wb_valD_sel,
    input wire [31:0]   regM_i_valE,
    

    //
    input wire [31:0]   memory_i_valM,

    input wire regM_branch_jump_i,

    //commit
    input wire  [31:0]  regM_i_pc,
    input wire  [31:0]  regM_i_instr,
    input wire          regM_i_commit,
    input wire [31:0]   regM_i_pre_pc,


    input wire[ 9:0]  regM_opcode_info_i,
    input wire[ 9:0]  regM_alu_info_i,
    input wire[ 5:0]  regM_branch_info_i,
    input wire[ 7:0]  regM_load_store_info_i,
    input wire[ 5:0]  regM_csr_info_i,


    output reg          regW_o_wb_reg_wen,
    output reg [4:0]    regW_o_wb_rd,
    output wire [1:0]   regW_o_wb_valD_sel,
    output reg [31:0]   regW_o_valE,
    output reg [31:0]   regW_o_valM,
    output reg   regW_branch_jump_o,
    //commit
    output reg [31:0]   regW_o_pc,
    output reg [31:0]   regW_o_instr,
    output reg          regW_o_commit,
    output reg [31:0]   regW_o_pre_pc,

    output wire[ 9:0]  regW_opcode_info_o,
    output wire[ 9:0]  regW_alu_info_o,
    output wire[ 5:0]  regW_branch_info_o,
    output wire[ 7:0]  regW_load_store_info_o,
    output wire[ 5:0]  regW_csr_info_o            
);


always @(posedge clk)begin
    if(rst) begin
        regW_o_wb_reg_wen   <= `reg_wen_no_w;
        regW_o_wb_rd        <=  5'd0;
        regW_o_valE         <=  32'd0;
        regW_o_pc           <= 32'd0;
        regW_o_commit       <= 1'd0;
        regW_o_valM         <= 32'd0;
        regW_branch_jump_o <= 1'd0;
        regW_o_wb_valD_sel <= 2'd0;

        regW_opcode_info_o <= 10'd0;
	    regW_alu_info_o <= 10'd0;
	    regW_branch_info_o <= 6'd0;
	    regW_load_store_info_o <= 8'd0;
	    regW_csr_info_o <= 6'd0;
        
    end
    else begin
        regW_o_wb_reg_wen   <= regM_i_wb_reg_wen;
        regW_o_wb_rd        <= regM_i_wb_rd;
        regW_o_valE         <= regM_i_valE;
        regW_o_valM         <= memory_i_valM;
        regW_branch_jump_o <= regM_branch_jump_i;
        //commit
        regW_o_pc           <= regM_i_pc;
        regW_o_instr        <= regM_i_instr;
        regW_o_commit       <= regM_i_commit;
        regW_o_pre_pc       <= regM_i_pre_pc;
        regW_o_wb_valD_sel <= regM_i_wb_valD_sel;

        regW_opcode_info_o <= regM_opcode_info_i;
	    regW_alu_info_o <= regM_alu_info_i;
	    regW_branch_info_o <= regM_branch_info_i;
	    regW_load_store_info_o <= regM_load_store_info_i;
	    regW_csr_info_o <= regM_csr_info_i;

    end
end
                                                                   
                                                                   
endmodule