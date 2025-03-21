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
// Last modified Date:     2025/02/21 19:14:44
// Last Version:           V1.0
// Descriptions:           
//----------------------------------------------------------------------------------------
// Created by:             Please Write You Name 
// Created date:           2025/02/21 19:14:44
// mail      :             Please Write mail 
// Version:                V1.0
// TEXT NAME:              regD.v
// PATH:                   ~/pipeline-cpu/IP/mycpu/regD.v
// Descriptions:           
//                         
//----------------------------------------------------------------------------------------
//****************************************************************************************//

module regD(
    input                               clk,
    input                               rst,
    input  wire             	ctrl_i_regD_bubble,
	input  wire 				ctrl_i_regD_stall,
	input wire 		[31:0]		fetch_i_instr,
	input wire 		[31:0]		regF_i_pc,
	input wire      [31:0]		fetch_i_pre_pc,
	input wire 					fetch_i_commit,
	input wire 					predict_taken,
	input wire 					hit,
	input wire [31:0]			btb_addr_i,

	output reg 		[31:0]		regD_o_instr,
	output reg 		[31:0]		regD_o_pc,
	output reg  	[31:0]		regD_o_pre_pc,
	output reg 					regD_o_commit,
	output reg                  regD_predict_taken_o,
	output reg                  regD_hit_o,
	output reg      [31:0]      regD_btb_addr_o


);

 always @(posedge clk) begin
	if(rst || ctrl_i_regD_bubble) begin
		regD_o_instr  <= `nop_instr;
		regD_o_commit <= `nop_commit;
		regD_o_pc     <= `nop_pc;
		regD_o_pre_pc <= `nop_pre_pc;
		regD_predict_taken_o <= 1'b0;
		regD_hit_o    <= 1'b0;
		regD_btb_addr_o <= 32'b0;

		
	end
	else if(~ctrl_i_regD_stall) begin
		regD_o_instr  <= fetch_i_instr;
		regD_o_commit <= fetch_i_commit;
		regD_o_pc     <= regF_i_pc;
		regD_o_pre_pc <= fetch_i_pre_pc;
		regD_predict_taken_o <= predict_taken;
		regD_hit_o <= hit;
		regD_btb_addr_o <= btb_addr_i;
		
	end
end   
                                                                   
                                                                   
endmodule