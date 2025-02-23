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
// Last modified Date:     2025/02/15 12:56:56
// Last Version:           V1.0
// Descriptions:           
//----------------------------------------------------------------------------------------
// Created by:             Please Write You Name 
// Created date:           
// mail      :             Please Write mail 
// Version:                V1.0
// TEXT NAME:              alu.v
// PATH:                   ~/single-cycle-cpu/IP/mycpu/alu.v
// Descriptions:           
//                         
//----------------------------------------------------------------------------------------
//****************************************************************************************//

module alu
#(WIDTH = 32, REG_WIDTH=5)
(
    input wire  [9:0]   opcode_info_i,
    input wire  [9:0]   alu_info_i,
	input wire  [5:0]   branch_info_i,	   
	input wire  [7:0]   load_store_info_i,
	   
	input wire  [WIDTH-1:0]  pc_i,
	input wire  [WIDTH-1:0]  rs1_data_i,
	input wire  [WIDTH-1:0]  rs2_data_i,
	input wire  [WIDTH-1:0]  imm_i,
	   
	output wire [WIDTH-1:0]  alu_result_o,   
	output wire [WIDTH-1:0]  mem_addr_o,
	output wire         alu_branch_jump_o,
	output wire [31:0]        pc_next_o
);

//opcode info 
wire op_alu_imm    = opcode_info_i[9];
wire op_alu        = opcode_info_i[8];
wire op_branch     = opcode_info_i[7];
wire op_jal        = opcode_info_i[6];
wire op_jalr       = opcode_info_i[5];
wire op_load       = opcode_info_i[4];
wire op_store      = opcode_info_i[3];
wire op_lui        = opcode_info_i[2];
wire op_auipc      = opcode_info_i[1];

//decode stage ALU Info 
wire  alu_add  = alu_info_i[9];  //ALU_ADD 9
wire  alu_sub  = alu_info_i[8];
wire  alu_sll  = alu_info_i[7];  
wire  alu_slt  = alu_info_i[6];
wire  alu_sltu = alu_info_i[5];
wire  alu_xor  = alu_info_i[4];  
wire  alu_srl  = alu_info_i[3];
wire  alu_sra  = alu_info_i[2];
wire  alu_or   = alu_info_i[1];
wire  alu_and  = alu_info_i[0];

//decode stage branch info
wire branch_beq  = branch_info_i[5];
wire branch_bne  = branch_info_i[4];
wire branch_blt  = branch_info_i[3];
wire branch_bge  = branch_info_i[2];
wire branch_bltu = branch_info_i[1];
wire branch_bgeu = branch_info_i[0];

wire result_sel_add     = alu_add | op_jal | op_jalr | op_lui | op_auipc;  
wire result_sel_sub     = alu_sub | op_branch;
wire result_sel_add_sub = result_sel_add | result_sel_sub;
wire result_sel_sll     = alu_sll;
wire result_sel_slt     = alu_slt;
wire result_sel_sltu    = alu_sltu;
wire result_sel_xor     = alu_xor;
wire result_sel_srl     = alu_srl;
wire result_sel_sra     = alu_sra;
wire result_sel_or      = alu_or;
wire result_sel_and     = alu_and;

wire [WIDTH-1 : 0] oprand_1;
wire [WIDTH-1 : 0] oprand_2;

assign oprand_1 = (op_jal | op_auipc | op_jalr) ? pc_i :
				   op_lui ? 0 : rs1_data_i; //jar PC+offset; lui imm<<12; auipc PC+(imm<<12); ecall ebreak 0;
assign oprand_2 = (op_lui | op_auipc | op_alu_imm | op_store | op_load) ? imm_i :
				   (op_jal | op_jalr) ? 4 : rs2_data_i;

wire [31:0]  alu_add_sub_result;
wire [31:0]  alu_slt_result;
wire [31:0]  alu_sll_result;
wire [31:0]  alu_sltu_result;
wire [31:0]  alu_xor_result;
wire [31:0]  alu_srl_result;
wire [31:0]  alu_sra_result;
wire [31:0]  alu_or_result;
wire [31:0]  alu_and_result;

wire [31:0]  alu_op_result;

wire [31:0]  adder_op1;
wire [31:0]  adder_op2;
wire [31:0]  adder_result;
wire         adder_cin;
wire         adder_cout;

assign  adder_op1 = oprand_1;
assign  adder_op2 = (result_sel_sub | alu_slt | alu_sltu) ? (~oprand_2) : oprand_2;
assign  adder_cin = (result_sel_sub | alu_slt | alu_sltu) ? 1'b1 : 1'b0;
assign {adder_cout, adder_result} = adder_op1 + adder_op2 +  {31'b0, adder_cin};

assign alu_add_sub_result = adder_result;


//slt 
/* rs1   rs2  rs1-rs2   set(rs1 < rs2) 
    1     0      -        1    
	0     0      1        1
	1     1      1        1
*/
assign alu_slt_result[31:1] = 31'b0;
assign alu_slt_result[0]    = ((oprand_1[31] & ~oprand_2[31]) |
                              (~(oprand_1[31] ^ oprand_2[31]) & alu_add_sub_result[31]));

//sltu
/* rs1   rs2  rs1-rs2   set(rs1 < rs2)    
	0     0      1        1
*/
assign alu_sltu_result[31:1] = 31'b0;
assign alu_sltu_result[0]    = ~adder_cout;

//
wire [5:0] shift_op2 = oprand_2[5:0];

//sll
assign alu_sll_result = oprand_1 << shift_op2;

//srl
assign alu_srl_result = oprand_1 >> shift_op2;

//sra
assign alu_sra_result = $signed(oprand_1) >>> shift_op2;

assign alu_and_result = oprand_1 & oprand_2;
assign alu_or_result  = oprand_1 | oprand_2;
assign alu_xor_result = oprand_1 ^ oprand_2;

//memory address
assign mem_addr_o = alu_add_sub_result;

assign alu_op_result = ({32{result_sel_add_sub}} & alu_add_sub_result) |
                       ({32{result_sel_sll}}     & alu_sll_result)     |
                       ({32{result_sel_slt}}     & alu_slt_result)     |
                       ({32{result_sel_sltu}}    & alu_sltu_result)    |
						({32{result_sel_xor}}     & alu_xor_result)     |
						({32{result_sel_srl}}     & alu_srl_result)     |
						({32{result_sel_sra}}     & alu_sra_result)     |
						({32{result_sel_or}}      & alu_or_result)      |
						({32{result_sel_and}}     & alu_and_result) ;

assign alu_result_o = alu_op_result;

//branch
//xor 用于比较两个数是否相等，相等则为0，不相等则为1
// | 操作， 如果操作数中有1，则结果为1，如果全为0，则结果为0
wire not_equal = (|alu_xor_result);
wire equal     = ~not_equal;

//小于等于
/* rs1   rs2  rs1-rs2   set(rs1 < rs2) 
    1     0      -        1    
    0     0      1        1
    1     1      1        1
*/
wire  less_than  = ((oprand_1[31] & ~oprand_2[31]) |
                   (~(oprand_1[31] ^ oprand_2[31]) & alu_add_sub_result[31]));

wire  less_than_u    = ~adder_cout;

wire  greater_than   =  ~less_than;

wire  greater_than_u =  ~less_than_u;

wire alu_branch_jump_os = (branch_beq  & equal)         |
                           (branch_bne  & not_equal)     |
							(branch_blt  & less_than)     |
							(branch_bge  & greater_than)  |
							(branch_bltu & less_than_u)   |
							(branch_bgeu & greater_than_u);


wire inst_jump = (op_jal | op_jalr | op_branch);
assign alu_branch_jump_o = inst_jump & (op_jalr | op_jal | alu_branch_jump_os);

wire [31:0] jump_pc_op1 = (op_jal | op_branch) ? pc_i :
                           op_jalr               ? rs1_data_i 
	       				           :  0;
											
wire [31:0] jump_pc_op2 = imm_i;

wire [31:0] pc_add_op1 = alu_branch_jump_o ? jump_pc_op1 : pc_i;
wire [31:0] pc_add_op2 = alu_branch_jump_o ? jump_pc_op2 : 4;

assign pc_next_o = pc_add_op1 + pc_add_op2;


endmodule