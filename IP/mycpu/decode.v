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
// Last modified Date:     2025/02/14 15:04:47
// Last Version:           V1.0
// Descriptions:           
//----------------------------------------------------------------------------------------
// Created by:             Please Write You Name 
// Created date:           2025/02/14 15:04:47
// mail      :             Please Write mail 
// Version:                V1.0
// TEXT NAME:              decode.v
// PATH:                   ~/single-cycle-cpu/IP/mycpu/decode.v
// Descriptions:           
//                         
//----------------------------------------------------------------------------------------
//****************************************************************************************//

module decode
#(WIDTH = 32, REG_WIDTH=5)
(
    input                               clk,
    input                               rst,                      
    input wire [WIDTH - 1 : 0]          regD_i_instr,

	//写回阶段
	input wire  [31:0]	regW_i_valE,
	input wire  [31:0]	regW_i_valM,
	input wire 	[1:0]	regW_i_wb_valD_sel,
	input wire 	[4:0]	regW_i_wb_rd,
	input wire 			regW_i_wb_reg_wen,
	input wire  [31:0]  regW_i_pc,
	//访存阶段数据前递
	input  wire	[31:0]	regM_i_valE,
	input  wire [31:0]  regM_i_pc,
	input  wire [31:0]	memory_i_valM,
	input  wire [1:0]	regM_i_wb_valD_sel,
	input  wire [4:0] 	regM_i_wb_rd,
	input  wire 		regM_i_wb_reg_wen,

	//执行阶段数据前递
	input  wire 		regE_i_wb_reg_wen,
	input  wire [4:0]	regE_i_wb_rd,
	input  wire [31:0]	execute_i_valE,


    input wire 		  	write_back_i_wb_reg_wen,
	input wire [4:0] 	write_back_i_wb_rd,
    input wire [WIDTH - 1 : 0]   write_back_i_wb_valD,

	output wire [ 4:0]  decode_rs1_id_o,
	output wire [ 4:0]  decode_rs2_id_o,
	output wire [ 4:0]  decode_rd_id_o,
	output wire [11:0]  decode_csr_id_o,

	output wire [1:0]  	decode_o_wb_valD_sel,


    output wire[ 9:0]  decode_opcode_info_o,
	output wire[ 9:0]  decode_alu_info_o,
	output wire[ 5:0]  decode_branch_info_o,
	output wire[ 7:0]  decode_load_store_info_o,
	output wire[ 5:0]  decode_csr_info_o,


    output wire [WIDTH - 1 : 0]         decode_o_valA,
    output wire [WIDTH - 1 : 0]         decode_o_valB,
    output wire [WIDTH - 1 : 0]         decode_o_imm,
	output wire decode_o_need_jump,
	output wire decode_o_wb_reg_wen,
	output wire decode_isBranch_o

);

wire[31:0] fetch_inst_i = regD_i_instr;
wire [6:0] opcode = fetch_inst_i[ 6: 0];
wire [4:0] rd     = fetch_inst_i[11: 7];
wire [2:0] funct3 = fetch_inst_i[14:12];
wire [4:0] rs1    = fetch_inst_i[19:15];
wire [4:0] rs2    = fetch_inst_i[24:20];
wire [6:0] funct7 = fetch_inst_i[31:25];


assign decode_csr_id_o = fetch_inst_i[31:20];

//reg-imm
wire inst_alu_imm   = (opcode == 7'b00_100_11);

//reg-reg
wire inst_alu       = (opcode == 7'b01_100_11);

wire inst_jal       = (opcode == 7'b11_011_11);
wire inst_jalr      = (opcode == 7'b11_001_11);
wire inst_branch    = (opcode == 7'b11_000_11);

wire inst_load      = (opcode == 7'b00_000_11);
wire inst_store     = (opcode == 7'b01_000_11);
wire inst_lui       = (opcode == 7'b01_101_11);

wire inst_auipc     = (opcode == 7'b00_101_11);

wire inst_system    = (opcode == 7'b111_00_11);

wire rv32I_U_TYPE = inst_lui | inst_auipc;


//ALU op reg-imm
wire inst_addi  = inst_alu_imm   & (funct3 == 3'b000);
wire inst_slli  = inst_alu_imm   & (funct3 == 3'b001) & (funct7 == 7'b00_000_00);
wire inst_slti  = inst_alu_imm   & (funct3 == 3'b010);
wire inst_sltiu = inst_alu_imm   & (funct3 == 3'b011);
wire inst_xori  = inst_alu_imm   & (funct3 == 3'b100);
wire inst_srli  = inst_alu_imm   & (funct3 == 3'b101) & (funct7 == 7'b00_000_00);
wire inst_srai  = inst_alu_imm   & (funct3 == 3'b101) & (funct7 == 7'b01_000_00);
wire inst_ori   = inst_alu_imm   & (funct3 == 3'b110);
wire inst_andi  = inst_alu_imm   & (funct3 == 3'b111);

wire inst_add   = inst_alu   & (funct3 == 3'b000) & (funct7 == 7'b00_000_00);
wire inst_sub   = inst_alu   & (funct3 == 3'b000) & (funct7 == 7'b01_000_00);
wire inst_sll   = inst_alu   & (funct3 == 3'b001) & (funct7 == 7'b00_000_00);
wire inst_slt   = inst_alu   & (funct3 == 3'b010) & (funct7 == 7'b00_000_00);
wire inst_sltu  = inst_alu   & (funct3 == 3'b011) & (funct7 == 7'b00_000_00);
wire inst_xor   = inst_alu   & (funct3 == 3'b100) & (funct7 == 7'b00_000_00);
wire inst_srl   = inst_alu   & (funct3 == 3'b101) & (funct7 == 7'b00_000_00);
wire inst_sra   = inst_alu   & (funct3 == 3'b101) & (funct7 == 7'b01_000_00);
wire inst_or    = inst_alu   & (funct3 == 3'b110) & (funct7 == 7'b00_000_00);
wire inst_and   = inst_alu   & (funct3 == 3'b111) & (funct7 == 7'b00_000_00);

wire inst_beq   = inst_branch & (funct3 == 3'b000);
wire inst_bne   = inst_branch & (funct3 == 3'b001);
wire inst_blt   = inst_branch & (funct3 == 3'b100);
wire inst_bge   = inst_branch & (funct3 == 3'b101);
wire inst_bltu  = inst_branch & (funct3 == 3'b110);
wire inst_bgeu  = inst_branch & (funct3 == 3'b111);

//load instruction
wire inst_lb  = inst_load & (funct3 == 3'b000);
wire inst_lh  = inst_load & (funct3 == 3'b001);
wire inst_lw  = inst_load & (funct3 == 3'b010);
wire inst_lbu = inst_load & (funct3 == 3'b100);
wire inst_lhu = inst_load & (funct3 == 3'b101);

//store
wire inst_sb  = inst_store & (funct3 == 3'b000);
wire inst_sh  = inst_store & (funct3 == 3'b001);
wire inst_sw  = inst_store & (funct3 == 3'b010);

wire inst_ecall  = inst_system & (funct3 == 3'b000) & (fetch_inst_i[31:20] == 12'b0000_0000_0000);
wire inst_ebreak = inst_system & (funct3 == 3'b000) & (fetch_inst_i[31:20] == 12'b0000_0000_0001);
wire inst_mret   = inst_system & (funct3 == 3'b000) & (fetch_inst_i[31:20] == 12'b0011_0000_0010);

wire inst_csrrw  = inst_system & (funct3 == 3'b001);
wire inst_csrrs  = inst_system & (funct3 == 3'b010);
wire inst_csrrc  = inst_system & (funct3 == 3'b011);
wire inst_csrrwi = inst_system & (funct3 == 3'b101);
wire inst_csrrsi = inst_system & (funct3 == 3'b110);
wire inst_csrrci = inst_system & (funct3 == 3'b111);

assign decode_opcode_info_o = {
			        inst_alu_imm,    //9
					inst_alu,        //8
			        inst_branch,     //7
			        inst_jal,        //6
			        inst_jalr,       //5
			        inst_load,       //4
			        inst_store,      //3
			        inst_lui,        //2
			        inst_auipc,      //1
			        inst_system      //0
};

assign decode_alu_info_o = {
			     (inst_add  | inst_addi ),  // 9
			     (inst_sub              ),  // 8
                 (inst_sll  | inst_slli ),  // 7
			     (inst_slt  | inst_slti ),  // 6
			     (inst_sltu | inst_sltiu),  // 5
			     (inst_xor  | inst_xori ),  // 4
			     (inst_srl  | inst_srli ),  // 3
			     (inst_sra  | inst_srai ),  // 2
			     (inst_or   | inst_ori  ),  // 1
			     (inst_and  | inst_andi )   // 0   

 };

assign decode_branch_info_o = {
			        inst_beq,  // 5
			        inst_bne,  // 4
			        inst_blt,  // 3
			        inst_bge,  // 2
			        inst_bltu, // 1
			        inst_bgeu  // 0						
};

assign decode_load_store_info_o = {
			           inst_lb,  // 7 
				   inst_lh,  // 6
				   inst_lw,  // 5
				   inst_lbu, // 4
				   inst_lhu, // 3
				   inst_sb,  // 2
				   inst_sh,  // 1
				   inst_sw   // 0								
};

assign decode_csr_info_o = {
		         inst_csrrw,   // 5
			     inst_csrrs,   // 4
			     inst_csrrc,   // 3
			     inst_csrrwi,  // 2
			     inst_csrrsi,  // 1
			     inst_csrrci   // 0
};

wire decode_ecall_o  = inst_ecall;
wire decode_ebreak_o = inst_ebreak;
wire decode_mret_o   = inst_mret;

//lui auipc jal 
//csr
//ecall
wire inst_need_rs1 = (~inst_lui)    & (~inst_auipc)  & (~inst_jal)    &
	            		 (~inst_csrrwi) & (~inst_csrrsi) & (~inst_csrrci) &
		    		 (~inst_ecall)  & (~inst_ebreak) & (~inst_mret);
					 

wire inst_need_rs2 = (inst_alu | inst_branch | inst_store);


wire inst_need_rd = (~inst_ecall)  & (~inst_ebreak) & (~inst_mret) &
                    (~inst_branch) & (~inst_store);

wire inst_need_csr = inst_csrrw  | inst_csrrs  | inst_csrrc |
                     inst_csrrwi | inst_csrrsi | inst_csrrci;


//assign decode_csr_wen_o = inst_need_csr;	


wire [31:0] inst_i_imm = { {20{fetch_inst_i[31]}}, fetch_inst_i[31:20] };		
wire [31:0] inst_s_imm = { {20{fetch_inst_i[31]}}, fetch_inst_i[31:25], fetch_inst_i[11:7] };	
wire [31:0] inst_b_imm = { {19{fetch_inst_i[31]}}, fetch_inst_i[31],    fetch_inst_i[7],      fetch_inst_i[30:25], fetch_inst_i[11:8 ], 1'b0};
wire [31:0] inst_j_imm = { {11{fetch_inst_i[31]}}, fetch_inst_i[31],    fetch_inst_i[19:12],  fetch_inst_i[20],    fetch_inst_i[30:21], 1'b0};	
wire [31:0] inst_u_imm = { fetch_inst_i[31:12], 12'b0};			 

wire inst_imm_sel_i = inst_alu_imm | inst_load | inst_jalr;
wire inst_imm_sel_s = inst_store;
wire inst_imm_sel_b = inst_branch;
wire inst_imm_sel_j = inst_jal;
wire inst_imm_sel_u = inst_lui | inst_auipc;

wire [31:0] inst_imm = ({32{inst_imm_sel_i}} & inst_i_imm) |
		       ({32{inst_imm_sel_s}} & inst_s_imm) |
		       ({32{inst_imm_sel_b}} & inst_b_imm) |
		       ({32{inst_imm_sel_j}} & inst_j_imm) |
		       ({32{inst_imm_sel_u}} & inst_u_imm);
						 
assign decode_o_imm = inst_imm;
    
wire [31:0] regfile_o_valA;
wire [31:0] regfile_o_valB;
    regfile regfile_module(
        .clk(clk),
        .rst(rst),
        
        .d_rs1_i(decode_rs1_id_o),
        .d_rs2_i(decode_rs2_id_o),
        .d_rd_i(write_back_i_wb_rd),
		.d_reg_wen_i(write_back_i_wb_reg_wen),
        .d_valWB_i(write_back_i_wb_valD),

        .reg_valA_o(regfile_o_valA),
        .reg_valB_o(regfile_o_valB)
    );

assign decode_rs1_id_o = inst_need_rs1 ? rs1 : 5'd0;

assign decode_rs2_id_o = inst_need_rs2 ? rs2 : 5'd0;

assign decode_rd_id_o = inst_need_rd ? rd : 5'd0;


assign decode_o_valA = (decode_rs1_id_o  == regE_i_wb_rd && regE_i_wb_rd != 5'd0 &&  regE_i_wb_reg_wen) ? execute_i_valE : 
						 (decode_rs1_id_o  == regM_i_wb_rd && regM_i_wb_rd != 5'd0 &&  regM_i_wb_reg_wen && regM_i_wb_valD_sel == `wb_valD_sel_valM) ? memory_i_valM 		: 
						 (decode_rs1_id_o  == regM_i_wb_rd && regM_i_wb_rd != 5'd0 &&  regM_i_wb_reg_wen && regM_i_wb_valD_sel == `wb_valD_sel_valE) ? regM_i_valE 		: 
						 (decode_rs1_id_o  == regM_i_wb_rd && regM_i_wb_rd != 5'd0 &&  regM_i_wb_reg_wen && regM_i_wb_valD_sel == `wb_valD_sel_valP) ? regM_i_pc + 32'd4   :
						 (decode_rs1_id_o  == regW_i_wb_rd && regW_i_wb_rd != 5'd0 &&  regW_i_wb_reg_wen && regW_i_wb_valD_sel == `wb_valD_sel_valE) ? regW_i_valE  		: 
						 (decode_rs1_id_o  == regW_i_wb_rd && regW_i_wb_rd != 5'd0 &&  regW_i_wb_reg_wen && regW_i_wb_valD_sel == `wb_valD_sel_valM) ? regW_i_valM  		: 
						 (decode_rs1_id_o  == regW_i_wb_rd && regW_i_wb_rd != 5'd0 &&  regW_i_wb_reg_wen && regW_i_wb_valD_sel == `wb_valD_sel_valP) ? regW_i_pc + 32'd4   : regfile_o_valA;

assign decode_o_valB = (decode_rs2_id_o  == regE_i_wb_rd && regE_i_wb_rd != 5'd0 && regE_i_wb_reg_wen) ? execute_i_valE : 
						 (decode_rs2_id_o  == regM_i_wb_rd && regM_i_wb_rd != 5'd0 && regM_i_wb_reg_wen && regM_i_wb_valD_sel == `wb_valD_sel_valM) ? memory_i_valM : 
						 (decode_rs2_id_o  == regM_i_wb_rd && regM_i_wb_rd != 5'd0 && regM_i_wb_reg_wen && regM_i_wb_valD_sel == `wb_valD_sel_valE) ? regM_i_valE  :
						 (decode_rs2_id_o  == regM_i_wb_rd && regM_i_wb_rd != 5'd0 && regM_i_wb_reg_wen && regM_i_wb_valD_sel == `wb_valD_sel_valP) ? regM_i_pc + 32'd4  :
						 (decode_rs2_id_o  == regW_i_wb_rd && regW_i_wb_rd != 5'd0 && regW_i_wb_reg_wen && regW_i_wb_valD_sel == `wb_valD_sel_valE) ? regW_i_valE  : 
						 (decode_rs2_id_o  == regW_i_wb_rd && regW_i_wb_rd != 5'd0 && regW_i_wb_reg_wen && regW_i_wb_valD_sel == `wb_valD_sel_valM) ? regW_i_valM  : 
						 (decode_rs2_id_o  == regW_i_wb_rd && regW_i_wb_rd != 5'd0 &&  regW_i_wb_reg_wen && regW_i_wb_valD_sel == `wb_valD_sel_valP) ? regW_i_pc + 32'd4   : regfile_o_valB;

//确定一个指令是否需要读写内存

assign decode_o_wb_reg_wen = inst_need_rd;

assign  decode_o_wb_valD_sel 	=   (inst_alu | inst_alu_imm | rv32I_U_TYPE)   	? `wb_valD_sel_valE :
		    					 	(inst_load)                  						    ? `wb_valD_sel_valM :
									(inst_jalr   | inst_jal)               			    ? `wb_valD_sel_valP : `wb_valD_sel_valM;

assign decode_o_need_jump = (inst_beq && ($signed(decode_o_valA) == $signed(decode_o_valB)))  ? 1'b1:
							(inst_bne && ($signed(decode_o_valA) != $signed(decode_o_valB)))  ? 1'b1:
							(inst_blt && ($signed(decode_o_valA) < $signed( decode_o_valB)))  ? 1'b1:
							(inst_bge && ($signed(decode_o_valA) >= $signed(decode_o_valB)))  ? 1'b1:
							(inst_bltu && ($unsigned(decode_o_valA) < $unsigned(decode_o_valB)))  ? 1'b1:
							(inst_bgeu && ($unsigned(decode_o_valA) >= $unsigned(decode_o_valB))) ? 1'b1:
							(inst_jal | inst_jalr) ? 1'b1 : 1'b0;

assign decode_isBranch_o = inst_branch | inst_jal | inst_jalr;


endmodule

