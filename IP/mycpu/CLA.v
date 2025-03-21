module CLA_64bit (
    input  [63:0] a,       // 来自华莱士树的压缩和
    input  [63:0] b,       // 来自华莱士树的压缩进位（左移1位后）
    output [63:0] sum      // 64位乘积结果（高32位=MULH，低32位=MUL）
);
    // -------------------- 生成（G）和传播（P）信号 --------------------
    wire [63:0] G = a & b; // 生成信号：a_i AND b_i
    wire [63:0] P = a | b; // 传播信号：a_i OR b_i

    // -------------------- 前缀网络（Kogge-Stone结构） --------------------
    // Level 1（跨度1）
    wire [63:0] G1, P1;
    assign G1[0] = G[0];
    assign P1[0] = P[0];
    generate
        for (genvar i=1; i<64; i++) begin : level1
            assign G1[i] = G[i] | (P[i] & G[i-1]);
            assign P1[i] = P[i] & P[i-1];
        end
    endgenerate

    // Level 2（跨度2）
    wire [63:0] G2, P2;
    assign G2[0:1] = G1[0:1];
    assign P2[0:1] = P1[0:1];
    generate
        for (genvar i=2; i<64; i++) begin : level2
            assign G2[i] = G1[i] | (P1[i] & G1[i-2]);
            assign P2[i] = P1[i] & P1[i-2];
        end
    endgenerate

    // Level 3（跨度4）
    wire [63:0] G3, P3;
    assign G3[0:3] = G2[0:3];
    assign P3[0:3] = P2[0:3];
    generate
        for (genvar i=4; i<64; i++) begin : level3
            assign G3[i] = G2[i] | (P2[i] & G2[i-4]);
            assign P3[i] = P2[i] & P2[i-4];
        end
    endgenerate

    // Level 4（跨度8）至 Level 6（跨度32），类似递归扩展...

    wire [63:0] G4, P4;
    assign G4[0:7] = G3[0:7];
    assign P4[0:7] = P3[0:7];
    generate
        for (genvar i=8; i<64; i++) begin : level4
            assign G4[i] = G3[i] | (P3[i] & G3[i-8]);
            assign P4[i] = P3[i] & P3[i-8];
        end
    endgenerate

    //Level 5（跨度16）
    wire [63:0] G5, P5;
    assign G5[0:15] = G4[0:15];
    assign P5[0:15] = P4[0:15];
    generate
        for (genvar i=16; i<64; i++) begin : level5
            assign G5[i] = G4[i] | (P4[i] & G4[i-16]);
            assign P5[i] = P4[i] & P4[i-16];
        end
    endgenerate

    //Level 6（跨度32）

    wire [63:0] G6, P6;
    assign G6[0:31] = G5[0:31];
    assign P6[0:31] = P5[0:31];
    generate
        for (genvar i=32; i<64; i++) begin : level6
            assign G6[i] = G5[i] | (P5[i] & G5[i-32]);
            assign P6[i] = P5[i] & P5[i-32];
        end
    endgenerate

    // -------------------- 最终进位计算 --------------------
    wire [63:0] C; // 进位链
    assign C[0] = 1'b0; // 初始进位为0（华莱士树已处理进位左移）
    generate
        for (genvar i=1; i<64; i++) begin : carry
            assign C[i] = G6[i] | (P6[i] & C[i-1]);
        end
    endgenerate

    // -------------------- 和位计算 --------------------
    assign sum = a ^ b ^ C;
endmodule