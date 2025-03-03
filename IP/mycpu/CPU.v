//CPU模块, 不可修改，你的处理器需要在此实例化各个模块
module CPU(
	input wire clk,
	input wire rst,

	output wire [31:0]          cur_pc,
    output                      commit,
    output wire [31:0]          commit_pc,
    output wire [31:0]          commit_pre_pc

);


wire [31:0] select_pc_o_pc;

select_pc u_select_pc(
    .fetch_i_pre_pc      	(fetch_o_pre_pc       ),    
    .execute_next_pc_i     	(execute_next_pc_o       ),
	.execute_branch_jump_i(execute_o_need_jump),

    .select_pc_o_pc      	(select_pc_o_pc       )
);


wire [31:0]  pc_next_o;

reg[31:0] regF_o_pc;
regF u_regF(
	.clk(clk),
	.rst(rst),
	.ctrl_i_regF_stall(ctrl_o_regF_stall),
	.select_pc_o_pc (select_pc_o_pc),
	.regF_o_pc (regF_o_pc)
);


wire [31:0] fetch_o_instr;
wire fetch_o_commit;
wire [31:0] fetch_o_pre_pc;
fetch u_fetch(
	.regF_i_pc(regF_o_pc),
	.fetch_o_pre_pc(fetch_o_pre_pc),
	.fetch_instr_o(fetch_o_instr),
	.fetch_commit_o(fetch_o_commit)


);

wire predict_taken;

TournamentPredictor perdict_stage(
    .clk(clk),
    .rst(rst),
    .regF_pc_i(regF_o_pc),
    .execute_pc_i(),
    .execute_branch(),
    .predict_taken(predict_taken)

);

wire [31:0] regD_o_pc;
wire        regD_o_commit;
wire [31:0] regD_o_instr;
wire [31:0] regD_o_pre_pc;

regD u_regD(
    .clk            	(clk             ),
    .rst            	(rst             ),
    .ctrl_i_regD_bubble(ctrl_o_regD_bubble),
    .ctrl_i_regD_stall  (ctrl_o_regD_stall),
    .regF_i_pc      	(regF_o_pc       ),
    .fetch_i_instr      (fetch_o_instr),
	.fetch_i_pre_pc 	(fetch_o_pre_pc  ),
    .fetch_i_commit 	(fetch_o_commit  ),
    .regD_o_pc      	(regD_o_pc       ),
	.regD_o_pre_pc  	(regD_o_pre_pc   ),
    .regD_o_commit  	(regD_o_commit   ),
    .regD_o_instr       (regD_o_instr)
);

wire [31:0] decode_o_valA;
wire [31:0] decode_o_valB;
wire [31:0] decode_o_imm;
wire[ 9:0]  decode_opcode_info_o;
wire[ 9:0]  decode_alu_info_o;
wire[ 5:0]  decode_branch_info_o;
wire[ 7:0]  decode_load_store_info_o;
wire[ 5:0]  decode_csr_info_o;
wire decode_o_wb_reg_wen;
wire [4:0] decode_o_wb_rd;
wire [1:0] decode_o_wb_valD_sel;
wire [4:0]  decode_o_rs1;
wire [4:0]  decode_o_rs2;
wire [11:0] decode_csr_id_o;

wire decode_o_need_jump;

decode u_decode(
    .clk                     	(clk                      ),
    .rst                     	(rst                      ),
    .regD_i_instr            	(regD_o_instr             ),

    .regE_i_wb_reg_wen          (regE_o_wb_reg_wen),
	.regE_i_wb_rd               (regE_o_wb_rd),
	.execute_i_valE             (execute_o_valE),
	
	.regW_i_valE(regW_o_valE),
	.regW_i_valM(regW_o_valM),
	.regW_i_wb_valD_sel(regW_o_wb_valD_sel),
	.regW_i_wb_rd(regW_o_wb_rd),
	.regW_i_wb_reg_wen(regW_o_wb_reg_wen),
    .regW_i_pc  (regW_o_pc),
	//访存阶段数据前递
	.regM_i_valE(regM_o_valE),
	.memory_i_valM(memory_o_valM),
	.regM_i_wb_valD_sel(regM_o_wb_valD_sel),
	.regM_i_wb_rd(regM_o_wb_rd),
	.regM_i_wb_reg_wen(regM_o_wb_reg_wen),

    .write_back_i_wb_reg_wen 	(write_back_o_wb_reg_wen  ),
    .write_back_i_wb_rd      	(write_back_o_wb_rd       ),
    .write_back_i_wb_valD    	(write_back_o_wb_valD     ),

    .decode_o_valA           	(decode_o_valA            ),
    .decode_o_valB           	(decode_o_valB            ),
    .decode_o_imm            	(decode_o_imm             ),
    
	.decode_opcode_info_o(decode_opcode_info_o),
	.decode_alu_info_o(decode_alu_info_o),
	.decode_branch_info_o(decode_branch_info_o),
	.decode_load_store_info_o(decode_load_store_info_o),
	.decode_csr_info_o(decode_csr_info_o),

    .decode_o_wb_reg_wen     	(decode_o_wb_reg_wen      ),
    .decode_rd_id_o          	(decode_o_wb_rd           ),
    .decode_o_wb_valD_sel    	(decode_o_wb_valD_sel     ),
    .decode_rs1_id_o       (decode_o_rs1),
    .decode_rs2_id_o( decode_o_rs2),
	.decode_csr_id_o(decode_csr_id_o),
    .decode_o_need_jump(decode_o_need_jump)
);

wire [31:0] regE_o_valA;
wire [31:0] regE_o_valB;
wire [31:0] regE_o_imm;

wire regE_o_wb_reg_wen;
wire [4:0] regE_o_wb_rd;
wire [1:0] regE_o_wb_valD_sel;

wire [31:0] regE_o_pc;
wire regE_o_commit;
wire [31:0] regE_o_instr;
wire [31:0] regE_o_pre_pc;

wire[ 9:0]  regE_opcode_info_o;
wire[ 9:0]  regE_alu_info_o;
wire[ 5:0]  regE_branch_info_o;
wire[ 7:0]  regE_load_store_info_o;
wire[ 5:0]  regE_csr_info_o;

wire regE_o_need_jump;

regE u_regE(
    .clk                   	(clk                    ),
    .rst                   	(rst                    ),
    .ctrl_i_regE_bubble    	(ctrl_o_regE_bubble     ),
    .decode_i_valA         	(decode_o_valA          ),
    .decode_i_valB         	(decode_o_valB          ),
    .decode_i_imm          	(decode_o_imm           ),

	.decode_opcode_info_i(decode_opcode_info_o),
	.decode_alu_info_i(decode_alu_info_o),
	.decode_branch_info_i(decode_branch_info_o),
	.decode_load_store_info_i(decode_load_store_info_o),
	.decode_csr_info_i(decode_csr_info_o),

    .decode_i_wb_reg_wen   	(decode_o_wb_reg_wen    ),
    .decode_i_wb_rd        	(decode_o_wb_rd         ),
    .decode_i_wb_valD_sel  	(decode_o_wb_valD_sel   ),
    .decode_i_need_jump (decode_o_need_jump),

    .regD_i_instr          	(regD_o_instr           ),
    .regD_i_pc             	(regD_o_pc              ),
    .regD_i_commit         	(regD_o_commit          ),
    .regD_i_pre_pc         	(regD_o_pre_pc          ),

    .regE_o_valA           	(regE_o_valA            ),
    .regE_o_valB           	(regE_o_valB            ),
    .regE_o_imm            	(regE_o_imm             ),

    .regE_o_wb_reg_wen     	(regE_o_wb_reg_wen      ),
    .regE_o_wb_rd          	(regE_o_wb_rd           ),
    .regE_o_wb_valD_sel    	(regE_o_wb_valD_sel     ),
    .regE_o_pc             	(regE_o_pc              ),
    .regE_o_commit         	(regE_o_commit          ),
    .regE_o_instr          	(regE_o_instr           ),
    .regE_o_pre_pc         	(regE_o_pre_pc          ),

	.regE_opcode_info_o(regE_opcode_info_o),
	.regE_alu_info_o(regE_alu_info_o),
	.regE_branch_info_o(regE_branch_info_o),
	.regE_load_store_info_o(regE_load_store_info_o),
	.regE_csr_info_o(regE_csr_info_o),

    .regE_o_need_jump(regE_o_need_jump)
);


wire [31:0] execute_mem_addr_o;
wire [31:0] execute_o_valE;
wire [31:0] execute_next_pc_o;
wire execute_branch_jump_o;
wire execute_o_need_jump;



execute u_execute(

	.regE_opcode_info_i(regE_opcode_info_o),
	.regE_alu_info_i(regE_alu_info_o),
	.regE_branch_info_i(regE_branch_info_o),
	.regE_load_store_info_i(regE_load_store_info_o),
    .regE_i_need_jump(regE_o_need_jump),

    .regE_i_valA         	(regE_o_valA          ),
    .regE_i_valB         	(regE_o_valB          ),
    .regE_i_imm          	(regE_o_imm           ),
    .regE_i_pc           	(regE_o_pc            ),
    .regE_i_pre_pc       	(regE_o_pre_pc        ),
    .execute_mem_addr_o   	(execute_mem_addr_o     ),
    .execute_o_valE      	(execute_o_valE       ),
	.execute_branch_jump_o(execute_branch_jump_o),
	.execute_next_pc_o(execute_next_pc_o),
    .execute_o_need_jump(execute_o_need_jump)

);

// output declaration of module regM
wire [31:0] regM_o_valE;
wire [31:0] regM_mem_addr_o;
wire [3:0] regM_o_mem_rw;
wire regM_o_wb_reg_wen;
wire [4:0] regM_o_wb_rd;
wire [1:0] regM_o_wb_valD_sel;
wire [31:0] regM_o_instr;
wire [31:0] regM_o_pc;
wire regM_o_commit;
wire [31:0] regM_o_pre_pc;
wire [31:0] regM_o_valB;


wire[ 9:0]  regM_opcode_info_o;
wire[ 9:0]  regM_alu_info_o;
wire[ 5:0]  regM_branch_info_o;
wire[ 7:0]  regM_load_store_info_o;
wire[ 5:0]  regM_csr_info_o;

wire regM_branch_jump_o;


regM u_regM(
    .clk                	(clk                 ),
    .rst                	(rst                 ),
    .execute_i_valE     	(execute_o_valE      ),
	.execute_mem_addr_i(execute_mem_addr_o),
    //.execute_i_pre_pc   	(execute_o_pre_pc    ),
    .regE_i_wb_reg_wen  	(regE_o_wb_reg_wen   ),
    .regE_i_wb_rd       	(regE_o_wb_rd        ),
    .regE_i_wb_valD_sel 	(regE_o_wb_valD_sel  ),

	.regE_opcode_info_i(regE_opcode_info_o),
	.regE_alu_info_i(regE_alu_info_o),
	.regE_branch_info_i(regE_branch_info_o),
	.regE_load_store_info_i(regE_load_store_info_o),
	.regE_csr_info_i(regE_csr_info_o),
	.execute_branch_jump_i(execute_branch_jump_o),

    .regE_i_instr       	(regE_o_instr        ),
    .regE_i_pc          	(regE_o_pc           ),
    .regE_i_commit      	(regE_o_commit       ),
    .regE_i_valB            (regE_o_valB),
	.execute_i_pre_pc(execute_next_pc_o),

    .regM_o_valE        	(regM_o_valE         ),
	.regM_mem_addr_o(regM_mem_addr_o),

    .regM_o_valB            (regM_o_valB),
    .regM_o_wb_reg_wen  	(regM_o_wb_reg_wen   ),
    .regM_o_wb_rd       	(regM_o_wb_rd        ),
    .regM_o_wb_valD_sel 	(regM_o_wb_valD_sel  ),
    .regM_o_instr       	(regM_o_instr        ),
    .regM_o_pc          	(regM_o_pc           ),
    .regM_o_commit      	(regM_o_commit       ),
	.regM_o_pre_pc(regM_o_pre_pc),

	.regM_opcode_info_o(regM_opcode_info_o),
	.regM_alu_info_o(regM_alu_info_o),
	.regM_branch_info_o(regM_branch_info_o),
	.regM_load_store_info_o(regM_load_store_info_o),
	.regM_csr_info_o(regM_csr_info_o),
	.regM_branch_jump_o(regM_branch_jump_o)
);

// output declaration of module memory
wire [31:0] memory_o_valM;
memory_access u_memory(
    .rst(rst),
    .clk(clk),
    .regM_mem_addr_i   	(regM_mem_addr_o),
    .regM_load_store_info_i     (regM_load_store_info_o),
    .regM_write_data_i 	(regM_o_valB),
    .memory_read_data_o 	(memory_o_valM  )
);

wire regW_o_wb_reg_wen;
wire [4:0] regW_o_wb_rd;
wire [1:0] regW_o_wb_valD_sel;
wire [31:0] regW_o_valE;
wire [31:0] regW_o_pc;
wire [31:0] regW_o_instr;
wire regW_o_commit;
wire [31:0] regW_o_pre_pc;
wire [31:0] regW_o_valM;
wire regW_o_branch_jump_o;
wire[ 9:0]  regW_opcode_info_o;
wire[ 9:0]  regW_alu_info_o;
wire[ 5:0]  regW_branch_info_o;
wire[ 7:0]  regW_load_store_info_o;
wire[ 5:0]  regW_csr_info_o;
regW u_regW(
    .clk                	(clk                 ),
    .rst                	(rst                 ),
    .regM_i_wb_reg_wen  	(regM_o_wb_reg_wen   ),
    .regM_i_wb_rd       	(regM_o_wb_rd        ),
    .regM_i_wb_valD_sel 	(regM_o_wb_valD_sel  ),
    .regM_i_valE        	(regM_o_valE         ),
    .regM_i_pc          	(regM_o_pc           ),
    .regM_i_instr       	(regM_o_instr        ),
    .regM_i_commit      	(regM_o_commit       ),
	.regM_i_pre_pc      	(regM_o_pre_pc       ),

    .memory_i_valM          (memory_o_valM),
	.regM_branch_jump_i(regM_branch_jump_o),

	.regM_opcode_info_i(regM_opcode_info_o),
	.regM_alu_info_i(regM_alu_info_o),
	.regM_branch_info_i(regM_branch_info_o),
	.regM_load_store_info_i(regM_load_store_info_o),
	.regM_csr_info_i(regM_csr_info_o),

    .regW_o_wb_reg_wen  	(regW_o_wb_reg_wen   ),
    .regW_o_wb_rd       	(regW_o_wb_rd        ),
    .regW_o_wb_valD_sel 	(regW_o_wb_valD_sel  ),
    .regW_o_valE        	(regW_o_valE         ),
    .regW_o_valM            (regW_o_valM),
	.regW_branch_jump_o(regW_o_branch_jump_o),
    .regW_o_pc          	(regW_o_pc           ),
    .regW_o_instr       	(regW_o_instr        ),
    .regW_o_commit      	(regW_o_commit       ),
	.regW_o_pre_pc      	(regW_o_pre_pc       ),
	.regW_opcode_info_o(regW_opcode_info_o),
	.regW_alu_info_o(regW_alu_info_o),
	.regW_branch_info_o(regW_branch_info_o),
	.regW_load_store_info_o(regW_load_store_info_o),
	.regW_csr_info_o(regW_csr_info_o)
);


// output declaration of module write_back
wire write_back_o_wb_reg_wen;
wire [4:0] write_back_o_wb_rd;
wire [31:0] write_back_o_wb_valD;

write_back u_write_back(
    .regW_i_wb_reg_wen       	(regW_o_wb_reg_wen        ),
    .regW_i_wb_rd            	(regW_o_wb_rd             ),
	.opcode_info_i(regW_opcode_info_o),
    .regW_i_pc                  (regW_o_pc),
    .regW_i_wb_valD_sel      	(regW_o_wb_valD_sel       ),
    .mem_read_data_i                (regW_o_valM),
    .alu_result_i             	(regW_o_valE              ),
    .regW_i_instr               (regW_o_instr),

    .write_back_o_wb_reg_wen 	(write_back_o_wb_reg_wen  ),
    .write_back_o_wb_rd      	(write_back_o_wb_rd       ),
    .wb_rd_write_data_o    	(write_back_o_wb_valD     )
);

assign cur_pc = regF_o_pc;
assign commit = regW_o_commit;
assign commit_pc = regW_o_pc;
assign commit_pre_pc=regW_o_pre_pc;


// output declaration of module ctrl
wire ctrl_o_regF_stall;
wire ctrl_o_regD_stall;
wire ctrl_o_regE_stall;
wire ctrl_o_regM_stall;
wire ctrl_o_regW_stall;
wire ctrl_o_regF_bubble;
wire ctrl_o_regD_bubble;
wire ctrl_o_regE_bubble;
wire ctrl_o_regM_bubble;
wire ctrl_o_regW_bubble;

control u_ctrl(
    .execute_i_need_jump 	(execute_branch_jump_o  ),
    .decode_i_rs1        	(decode_o_rs1         ),
    .decode_i_rs2        	(decode_o_rs2         ),
    .regE_i_rd           	(regE_o_wb_rd            ),
    .regE_load_store_info_i       	(regE_load_store_info_o        ),
    .ctrl_o_regF_stall   	(ctrl_o_regF_stall    ),
    .ctrl_o_regD_stall   	(ctrl_o_regD_stall    ),
    .ctrl_o_regE_stall   	(ctrl_o_regE_stall    ),
    .ctrl_o_regM_stall   	(ctrl_o_regM_stall    ),
    .ctrl_o_regW_stall   	(ctrl_o_regW_stall    ),
    .ctrl_o_regF_bubble  	(ctrl_o_regF_bubble   ),
    .ctrl_o_regD_bubble  	(ctrl_o_regD_bubble   ),
    .ctrl_o_regE_bubble  	(ctrl_o_regE_bubble   ),
    .ctrl_o_regM_bubble  	(ctrl_o_regM_bubble   ),
    .ctrl_o_regW_bubble  	(ctrl_o_regW_bubble   )
);



endmodule