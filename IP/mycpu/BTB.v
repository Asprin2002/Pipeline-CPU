
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
// Last modified Date:     2025/02/25 22:58:17
// Last Version:           V1.0
// Descriptions:           
//----------------------------------------------------------------------------------------
// Created by:             Please Write You Name 
// Created date:           2025/02/25 22:58:17
// mail      :             Please Write mail 
// Version:                V1.0
// TEXT NAME:              BTB.v
// PATH:                   ~/pipeline-cpu/IP/mycpu/BTB.v
// Descriptions:           
//                         
//----------------------------------------------------------------------------------------
//****************************************************************************************//

module BTB #(
    parameter SIZE = 64,
    parameter TAG_BITS = 20

) (
    input                               clk,
    input                               rst,
    input [31:0]  pc_query,           // 查询时的PC
    output [31:0] target_addr,        // 预测的目标地址
    output reg    hit,                // BTB命中标志
    // 更新接口
    input         update_en,          // 更新使能
    input [31:0]  pc_update,          // 需要更新的PC
    input [31:0]  target_addr_update  // 新的目标地址
);

    // BTB存储结构：每个条目包含 {tag, target_addr}
  reg [TAG_BITS-1:0] tag_ram [0:SIZE-1];
  reg [31:0]         target_ram [0:SIZE-1];
  // 索引计算：用PC的中间位（避免低2位对齐问题）
  wire [log2(SIZE)-1:0] index = pc_query[log2(SIZE)+1:2];

  // 查询逻辑
  assign target_addr = target_ram[index];
  always @(*) begin
    hit = (tag_ram[index] == pc_query[31:32-TAG_BITS]);
  end

  // 更新逻辑（在EX阶段确认分支时写入）
  always @(posedge clk) begin
    if (rst) begin
      for (integer i=0; i<SIZE; i++) begin
        tag_ram[i] <= 0;
        target_ram[i] <= 0;
      end
    end else if (update_en) begin
      tag_ram[index_update] <= pc_update[31:32-TAG_BITS];
      target_ram[index_update] <= target_addr_update;
    end
  end
                                                                   
                                                                   
endmodule 