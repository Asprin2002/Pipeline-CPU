`include "define.v"
module write_back
#(WIDTH = 32)
(      input wire          regW_i_wb_reg_wen,
       input wire [4:0]    regW_i_wb_rd,
       input [9 : 0]   opcode_info_i,
       input[1:0] regW_i_wb_valD_sel,
       
       input [WIDTH-1 : 0]  alu_result_i,
       input [WIDTH-1 : 0]  mem_read_data_i,

       input wire [31:0]   regW_i_pc,
       
       input wire [31:0]   regW_i_instr,

       output wire         write_back_o_wb_reg_wen,
       output wire [4:0]   write_back_o_wb_rd,
       output[WIDTH-1 : 0]  wb_rd_write_data_o  
);

import "DPI-C" function void dpi_ebreak		(input int pc);

always @(*) begin
	if(regW_i_instr == 32'h00100073) begin
		dpi_ebreak(0);
	end
end

wire    op_load = opcode_info_i[4];

assign write_back_o_wb_rd   = regW_i_wb_rd;
assign write_back_o_wb_reg_wen = regW_i_wb_reg_wen;
assign  wb_rd_write_data_o = (regW_i_wb_valD_sel  == `wb_valD_sel_valE ) ?alu_result_i : 
                              (regW_i_wb_valD_sel  == `wb_valD_sel_valP ) ?regW_i_pc + 32'd4 :
                              (regW_i_wb_valD_sel  == `wb_valD_sel_valM) ? mem_read_data_i  :  32'd0;




endmodule
