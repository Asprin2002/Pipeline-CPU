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
// Last modified Date:     2025/02/22 00:32:21
// Last Version:           V1.0
// Descriptions:           
//----------------------------------------------------------------------------------------
// Created by:             Please Write You Name 
// Created date:           
// mail      :             Please Write mail 
// Version:                V1.0
// TEXT NAME:              regE.v
// PATH:                   ~/pipeline-cpu/IP/mycpu/regE.v
// Descriptions:           
//                         
//----------------------------------------------------------------------------------------
//****************************************************************************************//

module regE(
    input                               clk,
    input                               rst,
    input ctrl_i_regE_bubble,

    input  wire [31:0]      decode_i_valA,
    input  wire [31:0]      decode_i_valB,
    input  wire [31:0]      decode_i_imm,

    input wire[ 9:0]  decode_opcode_info_i,
	input wire[ 9:0]  decode_alu_info_i,
	input wire[ 5:0]  decode_branch_info_i,
	input wire[ 7:0]  decode_load_store_info_i,
	input wire[ 5:0]  decode_csr_info_i,

    input  wire [1:0]       decode_i_wb_valD_sel,

    input  wire             decode_i_wb_reg_wen,
    input  wire [4:0]       decode_i_wb_rd,

    input  wire [31:0]      regD_i_instr,
    input  wire [31:0]      regD_i_pc,
    input  wire             regD_i_commit,
    input  wire [31:0]      regD_i_pre_pc,

    input wire decode_i_need_jump,
    input wire regD_predict_taken_i,
    input wire decode_isBranch_i,
    input wire regD_hit_i,
    input wire [31:0] regD_btb_addr_i,

    output reg [31:0]       regE_o_valA,
    output reg [31:0]       regE_o_valB,
    output reg [31:0]       regE_o_imm,

    output reg [1:0]        regE_o_wb_valD_sel,
    output wire[ 9:0]  regE_opcode_info_o,
	output wire[ 9:0]  regE_alu_info_o,
	output wire[ 5:0]  regE_branch_info_o,
	output wire[ 7:0]  regE_load_store_info_o,
	output wire[ 5:0]  regE_csr_info_o,

    //memory

	//write_back
    output reg              regE_o_wb_reg_wen,
	output reg [4:0]        regE_o_wb_rd,

    //commit
    output reg    [31:0]    regE_o_pc,
    output reg              regE_o_commit,
    output reg    [31:0]    regE_o_instr,
    output reg    [31:0]    regE_o_pre_pc,
    output reg regE_o_need_jump,
    output reg regE_predict_taken,
    output reg regE_isBranch_o,
    output reg regE_hit_o,
    output reg [31:0] regE_btb_addr_o

    
);


always @(posedge clk) begin
    if(rst || ctrl_i_regE_bubble) begin
        //execute
        regE_o_valA         <= 32'd0;
        regE_o_valB         <= 32'd0;
        regE_o_imm          <= 32'd0;
        regE_opcode_info_o <= 10'd0;
	    regE_alu_info_o <= 10'd0;
	    regE_branch_info_o <= 6'd0;
	    regE_load_store_info_o <= 8'd0;
	    regE_csr_info_o <= 6'd0;
        //memory
        //write_back
        regE_o_wb_reg_wen   <= `reg_wen_no_w;
        regE_o_wb_rd        <= 5'd0; 

        //commit for simulator
        regE_o_pc           <= 32'd0; 
        regE_o_commit       <= 1'd0;  
        regE_o_pre_pc       <= 32'd0;
        regE_o_need_jump <= 1'b0;
        regE_isBranch_o <= 1'b0;
        regE_predict_taken <= 1'b0;
		regE_hit_o    <= 1'b0;
		regE_btb_addr_o <= 32'b0;
    end
    else begin
        //execute
        regE_o_valA         <= decode_i_valA;
        regE_o_valB         <= decode_i_valB;
        regE_o_imm          <= decode_i_imm;
        regE_opcode_info_o <= decode_opcode_info_i;
	    regE_alu_info_o <= decode_alu_info_i;
	    regE_branch_info_o <= decode_branch_info_i;
	    regE_load_store_info_o <= decode_load_store_info_i;
	    regE_csr_info_o <= decode_csr_info_i;
        //memory
        //write_back
        regE_o_wb_reg_wen   <= decode_i_wb_reg_wen;
        regE_o_wb_rd        <= decode_i_wb_rd;
        regE_o_wb_valD_sel  <= decode_i_wb_valD_sel;


        //commit for simulator
        regE_o_instr        <= regD_i_instr;
        regE_o_pc           <= regD_i_pc;  
        regE_o_commit       <= regD_i_commit;
        regE_o_pre_pc       <= regD_i_pre_pc;
        regE_o_need_jump <= decode_i_need_jump;
        regE_isBranch_o <= decode_isBranch_i;
        regE_hit_o <= regD_hit_i;
        regE_predict_taken <= regD_predict_taken_i;
        regE_btb_addr_o <= regD_btb_addr_i;
    end
end
                                                                   
                                                                   
endmodule