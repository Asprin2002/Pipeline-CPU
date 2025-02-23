//fetch模块，仅供参考，可以随意修改
`include "define.v"
module fetch
#(WIDTH=32)
(
	input wire [31:0] regF_i_pc,
	output wire [31:0] fetch_o_pre_pc,
	output wire [31:0] fetch_instr_o,
	output wire fetch_commit_o
);
import "DPI-C" function int  dpi_mem_read 	(input int addr  , input int len);


assign fetch_o_pre_pc = regF_i_pc + 32'd4;
assign fetch_instr_o = dpi_mem_read(regF_i_pc, 4);
assign fetch_commit_o = 1;

endmodule