module TournamentPredictor #(
  parameter META_TABLE_SIZE = 256,
  parameter LOCAL_HIST_BITS = 3,
  parameter GLOBAL_HIST_BITS = 8
)(
  input clk, rst,
  input [31:0] regF_pc_i,
  input [31:0] execute_pc_i,
  input branch_taken,
  input execute_isBranch_i,
  input [31:0] fetch_inst_i,
  output predict_taken,
  output local_pre,
  output global_pre,
  output isGlobal,
  output is_jump
);
  assign local_pre = local_pred;
  assign global_pre = global_pred;
  assign isGlobal = use_global;
  wire [6:0] opcode = fetch_inst_i[ 6: 0];
  wire inst_jal       = (opcode == 7'b11_011_11);
  wire inst_jalr      = (opcode == 7'b11_001_11);
  wire inst_branch    = (opcode == 7'b11_000_11);
  wire must_jump = inst_jal | inst_jalr;
  assign is_jump = must_jump | inst_branch;

  //fetch_pre
  // 1. 局部预测器（以2-bit饱和计数器为例）
  reg [LOCAL_HIST_BITS-1:0] lhr [0:META_TABLE_SIZE-1];  // 局部历史寄存器表
  reg [1:0] local_pht [0:(1<<LOCAL_HIST_BITS) - 1];  // 局部模式历史表
  wire [7:0] local_index_pre = regF_pc_i[9:2];
  wire [LOCAL_HIST_BITS-1:0] local_history_pre = lhr[local_index_pre];
  wire [1:0] local_counter = local_pht[local_history_pre];
  wire local_pred = local_counter[1];

  // 2. 全局预测器（GShare）
  reg [GLOBAL_HIST_BITS-1:0] ghr;
  reg [1:0] global_pht [0:(1<<GLOBAL_HIST_BITS)-1]; // 全局模式历史表
  wire [GLOBAL_HIST_BITS-1:0] global_index_pre = ghr ^ regF_pc_i[GLOBAL_HIST_BITS+1:2];
  wire [1:0] global_counter = global_pht[global_index_pre];
  wire global_pred = global_counter[1]; // 全局预测结果


  // 3. 元预测器
  reg [1:0] meta_table [0:META_TABLE_SIZE-1];
  wire [7:0] meta_index = regF_pc_i[9:2];
  wire use_global = meta_table[meta_index][1]; // 高位为1则选择全局

  // 最终预测输出
  assign predict_taken = must_jump ? 1'b1 :
                         inst_branch ? (use_global ? global_pred : local_pred) :
                         1'b0;
  
  

  //execute_

  //local predictor
  wire [7:0] local_index_exe = execute_pc_i[9:2];
  wire [LOCAL_HIST_BITS-1:0] local_history_exe = lhr[local_index_exe];
  wire [1:0] local_counter_exe = local_pht[local_history_exe];
  wire local_pred_exe = local_counter_exe[1];

  // global predictor
  wire [GLOBAL_HIST_BITS-1:0] global_index_exe = ghr ^ execute_pc_i[GLOBAL_HIST_BITS+1:2];
  wire [1:0] global_counter_exe = global_pht[global_index_exe];
  wire global_pred_exe = global_counter_exe[1]; // 全局预测结果]

  wire [7:0] meta_index_exe = execute_pc_i[9:2];


  initial begin
      ghr = 8'b0;
      for (int i=0; i<META_TABLE_SIZE; i++) begin
        meta_table[i] = 2'b01; // 初始弱倾向局部
        lhr[i] = 3'b0;
      end
      for (int i=0; i<(1<<LOCAL_HIST_BITS); i++)
        local_pht[i] = 2'b01;
      for (int i=0; i<(1<<GLOBAL_HIST_BITS); i++)
        global_pht[i] = 2'b01;
  end
  // 更新逻辑
  always @(posedge clk) begin
     if(execute_isBranch_i) begin

        if (local_pred_exe != branch_taken && global_pred_exe == branch_taken) begin
          // 全局正确，局部错误 → 偏向全局
          meta_table[meta_index_exe] <= (meta_table[meta_index_exe] == 2'b11) ? 2'b11 : meta_table[meta_index_exe] + 1;
        end else if (local_pred_exe == branch_taken && global_pred_exe != branch_taken) begin
          // 局部正确，全局错误 → 偏向局部
          meta_table[meta_index_exe] <= (meta_table[meta_index_exe] == 2'b00) ? 2'b00 : meta_table[meta_index_exe] - 1;
        end
        
        if(branch_taken) begin
        //更新局部预测器
        lhr[local_index_exe] <= {local_history_exe[LOCAL_HIST_BITS-2 : 0], branch_taken};
        local_pht[local_history_exe] <= (local_counter_exe == 2'b11) ? 2'b11 : local_counter_exe + 2'b01;

        global_pht[global_index_exe] <= (global_counter_exe == 2'b11) ? 2'b11 : global_counter_exe + 1;
        ghr <= {ghr[GLOBAL_HIST_BITS-2:0], branch_taken};

        end
        else begin
          lhr[local_index_exe] <= {local_history_exe[LOCAL_HIST_BITS-2 : 0], branch_taken};
          local_pht[local_history_exe] <= (local_counter_exe == 2'b00) ? 2'b00 : local_counter_exe - 1;

          global_pht[global_index_exe] <= (global_counter_exe == 2'b00) ? 2'b00 : global_counter_exe - 1;
          ghr <= {ghr[GLOBAL_HIST_BITS-2:0], branch_taken};

        end

      // 更新元预测器
      
    end
    else begin
      lhr <= lhr;
      local_pht <= local_pht;
      ghr <= ghr;
      global_pht <= global_pht;
      meta_table <= meta_table;

    end

  end
endmodule