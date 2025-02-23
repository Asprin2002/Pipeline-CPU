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
// Last modified Date:     2025/02/21 19:08:41
// Last Version:           V1.0
// Descriptions:           
//----------------------------------------------------------------------------------------
// Created by:             Please Write You Name 
// Created date:           2025/02/21 19:08:41
// mail      :             Please Write mail 
// Version:                V1.0
// TEXT NAME:              Freg.v
// PATH:                   ~/pipeline-cpu/IP/mycpu/Freg.v
// Descriptions:           
//                         
//----------------------------------------------------------------------------------------
//****************************************************************************************//

module regF(
    input wire              clk,
    input wire              rst,
    input wire              ctrl_i_regF_stall,
    input wire [31:0]       select_pc_o_pc,
    output reg[31:0]        regF_o_pc              
);

always @(posedge clk) begin
    if(rst) begin
        regF_o_pc     <= 32'h80000000;
    end
    else if(~ctrl_i_regF_stall)begin
        regF_o_pc     <= select_pc_o_pc;
    end
end
                                                                   
                                                                   
endmodule