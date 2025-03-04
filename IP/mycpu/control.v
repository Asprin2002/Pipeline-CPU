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
// Last modified Date:     2025/02/22 03:35:16
// Last Version:           V1.0
// Descriptions:           
//----------------------------------------------------------------------------------------
// Created by:             Please Write You Name 
// Created date:           
// mail      :             Please Write mail 
// Version:                V1.0
// TEXT NAME:              control.v
// PATH:                   ~/pipeline-cpu/IP/mycpu/control.v
// Descriptions:           
//                         
//----------------------------------------------------------------------------------------
//****************************************************************************************//

module control(

    input  wire          execute_i_need_jump,
    input  wire          execute_branch_fix,
    input  wire          addr_fix_i

    input  wire   [4:0]  decode_i_rs1,
    input  wire   [4:0]  decode_i_rs2,
    input  wire   [4:0]  regE_i_rd,
    input  wire   [7:0]  regE_load_store_info_i,

    output wire          ctrl_o_regF_stall,
    output wire          ctrl_o_regD_stall,
    output wire          ctrl_o_regE_stall,
    output wire          ctrl_o_regM_stall,
    output wire          ctrl_o_regW_stall,

    output wire          ctrl_o_regF_bubble,
    output wire          ctrl_o_regD_bubble,
    output wire          ctrl_o_regE_bubble,
    output wire          ctrl_o_regM_bubble,
    output wire          ctrl_o_regW_bubble

);

//对于BEQ分支预测指令来说
//如果预测出错，应该冲刷

wire rv32_lb  = regE_load_store_info_i[7];
wire rv32_lh  = regE_load_store_info_i[6];
wire rv32_lw  = regE_load_store_info_i[5];
wire rv32_lbu = regE_load_store_info_i[4];
wire rv32_lhu = regE_load_store_info_i[3];
wire rv32_load = rv32_lb | rv32_lh | rv32_lw | rv32_lbu | rv32_lhu;


//加载使用冒险
wire load_use = (regE_i_rd == decode_i_rs1 || regE_i_rd == decode_i_rs2) && (rv32_load);
//分支预测错误
//wire branch_bubble = execute_i_need_jump;
wire branch_bubble = execute_branch_fix || addr_fix_i;

assign ctrl_o_regD_bubble   = branch_bubble;//branch_bubble;
assign ctrl_o_regE_bubble   = load_use || branch_bubble;//branch_bubble || load_use;

assign ctrl_o_regF_bubble   = 1'b0;
assign ctrl_o_regM_bubble   = 1'b0;
assign ctrl_o_regW_bubble   = 1'b0;

assign ctrl_o_regF_stall    = load_use;
assign ctrl_o_regD_stall    = load_use;
assign ctrl_o_regE_stall    = 1'b0;
assign ctrl_o_regM_stall    = 1'b0;
assign ctrl_o_regW_stall    = 1'b0;
                                                                   
                                                                   
endmodule