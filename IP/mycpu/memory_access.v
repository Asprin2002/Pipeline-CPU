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
// Last modified Date:     2025/02/15 12:38:28
// Last Version:           V1.0
// Descriptions:           
//----------------------------------------------------------------------------------------
// Created by:             Please Write You Name 
// Created date:           
// mail      :             Please Write mail 
// Version:                V1.0
// TEXT NAME:              memory_access.v
// PATH:                   ~/single-cycle-cpu/IP/mycpu/memory_access.v
// Descriptions:           
//                         
//----------------------------------------------------------------------------------------
//****************************************************************************************//


module memory_access
#(WIDTH = 32, REG_WIDTH=5)
(
    input wire                              clk,
	input wire rst,

    input wire [WIDTH-1 : 0] regM_mem_addr_i,
	input wire [7 : 0]  regM_load_store_info_i,
	input wire [WIDTH-1 : 0] regM_write_data_i,
	output wire  [WIDTH - 1: 0] memory_read_data_o                     
);

import "DPI-C" function void dpi_mem_write(input int addr, input int data, int len);
import "DPI-C" function int  dpi_mem_read (input int addr  , input int len);



wire inst_lb = regM_load_store_info_i[7];
wire inst_lh = regM_load_store_info_i[6];
wire inst_lw = regM_load_store_info_i[5];
wire inst_lbu = regM_load_store_info_i[4];
wire inst_lhu = regM_load_store_info_i[3];
wire inst_sb = regM_load_store_info_i[2];
wire inst_sh = regM_load_store_info_i[1];
wire inst_sw = regM_load_store_info_i[0];

wire mem_load_enable = (inst_lb | inst_lh | inst_lw | inst_lbu | inst_lhu);
reg[WIDTH-1 : 0] memory_read_data;
always @(*) begin
	if(mem_load_enable) begin
		memory_read_data = dpi_mem_read(regM_mem_addr_i, 4);
	end
	else begin
		memory_read_data = 32'b0;
	end
end

wire[WIDTH-1 : 0] lb_data = {{24{memory_read_data[7]}}, memory_read_data[7:0]};
wire[WIDTH-1 : 0] lh_data = {{16{memory_read_data[15]}}, memory_read_data[15:0]};
wire[WIDTH-1 : 0] lw_data = memory_read_data;
wire[WIDTH-1 : 0] lbu_data = {{24'b0},  memory_read_data[ 7:0]};
wire[WIDTH-1 : 0] lhu_data = {{16'b0},  memory_read_data[15:0]};


assign memory_read_data_o = (inst_lb)        ? lb_data        :
                            (inst_lh)        ? lh_data        :
			 		        (inst_lw)        ? lw_data        :
			 		        (inst_lbu)       ? lbu_data       :
			  		        (inst_lhu)       ? lhu_data       : memory_read_data;



always @(posedge clk) begin
	if(inst_sb) begin
		dpi_mem_write(regM_mem_addr_i, regM_write_data_i, 1);
	end
	else if(inst_sh) begin
		dpi_mem_write(regM_mem_addr_i, regM_write_data_i, 2);		
	end
	else if(inst_sw) begin
		dpi_mem_write(regM_mem_addr_i, regM_write_data_i, 4);				
	end
end


                                                                   
                                                                   
endmodule