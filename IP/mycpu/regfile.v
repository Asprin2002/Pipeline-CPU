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
// Last modified Date:     2025/02/14 21:04:26
// Last Version:           V1.0
// Descriptions:           
//----------------------------------------------------------------------------------------
// Created by:             Please Write You Name 
// Created date:           
// mail      :             Please Write mail 
// Version:                V1.0
// TEXT NAME:              reg.v
// PATH:                   ~/single-cycle-cpu/IP/mycpu/reg.v
// Descriptions:           
//                         
//----------------------------------------------------------------------------------------
//****************************************************************************************//

module regfile
#(WIDTH = 32, REG_WIDTH=5)
(
    input  wire                          clk,
    input  wire                          rst,

    input  wire[REG_WIDTH-1 : 0]         d_rs1_i,
    input  wire[REG_WIDTH-1 : 0]         d_rs2_i,
    input  wire[REG_WIDTH-1 : 0]         d_rd_i,

    input  wire                          d_reg_wen_i, // 'd' only represent where 
    input  wire[WIDTH-1 : 0]             d_valWB_i,   //  the signal come from directly.
    output wire[WIDTH-1 : 0]             reg_valA_o,
    output wire[WIDTH-1 : 0]             reg_valB_o
);

    reg [31:0] regfile[31:0];
    assign reg_valA_o = d_rs1_i == 5'd0 ? 32'd0 : regfile[d_rs1_i];
    assign reg_valB_o = d_rs2_i == 5'd0 ? 32'd0 : regfile[d_rs2_i];
    import "DPI-C" function void dpi_ebreak			(input int pc);
    import "DPI-C" function void dpi_read_regfile(input logic [31 : 0] a []);

    initial begin
        dpi_read_regfile(regfile);
    end

    initial begin
    integer i;
    for (i = 0; i < 32; i = i + 1) begin
        regfile[i] = i;
    end
    regfile[20] = 32'h80000000;
    end

    always @(posedge clk)           
        begin                                        
            if(rst) begin
                regfile[0] <= 32'h0;
            end                                                       
            else if (d_reg_wen_i && d_rd_i != 0) begin
                regfile[d_rd_i] <= d_valWB_i;
            end                                     
        end                                          
                                                                   
                                                                   
endmodule