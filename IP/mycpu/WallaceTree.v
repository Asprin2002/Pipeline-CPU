module WallaceTree #(
    parameter BIT_WIDTH = 64     // 部分积位宽
)(
    input  [BIT_WIDTH-1:0] pp_in [0:16], // Booth编码生成的17个部分积
    output [BIT_WIDTH-1:0] sum,          // 最终和
    output [BIT_WIDTH-1:0] carry         // 最终进位
);
    // -------------------- 定义中间层信号 --------------------
    // Layer 0: 输入层 (17个部分积)
    // Layer 1: 压缩后约12个部分积
    wire [BIT_WIDTH-1:0] layer1 [0:11];
    // Layer 2: 压缩后约8个部分积
    wire [BIT_WIDTH-1:0] layer2 [0:7];
    // Layer 3: 压缩后约6个部分积
    wire [BIT_WIDTH-1:0] layer3 [0:5];
    // Layer 4: 压缩后约4个部分积
    wire [BIT_WIDTH-1:0] layer4 [0:3];
    // Layer 5: 压缩后约3个部分积
    wire [BIT_WIDTH-1:0] layer5 [0:2];
    // Layer 6: 压缩后2个部分积（最终输出）
    wire [BIT_WIDTH-1:0] layer6 [0:1];

    // -------------------- Layer 0 → Layer 1 --------------------
    // 处理前12组（3个一组，共4组）
    genvar i;
    generate
        for (i=0; i<5; i=i+1) begin : layer0_compression
            FullAdderArray #(.WIDTH(BIT_WIDTH)) fa (
                .a(pp_in[3*i]),
                .b(pp_in[3*i+1]),
                .c_in(pp_in[3*i+2]),
                .s(layer1[2*i]),        // 和
                .c_out(layer1[2*i+1])   // 进位左移1位
            );
        end
        // 处理剩余5个部分积（17 - 12 = 5）
        // 前3个压缩为2个，后2个保留
        FullAdderArray #(.WIDTH(BIT_WIDTH)) fa_remain1 (
            .a(pp_in[12]), .b(pp_in[13]), .c_in(pp_in[14]),
            .s(layer1[8]), .c_out(layer1[9])
        );
        assign layer1[10] = pp_in[15];
        assign layer1[11] = pp_in[16];
    endgenerate

    // -------------------- Layer 1 → Layer 2 --------------------
    generate
        // 处理前8组（3个一组）
        for (i=0; i<4; i=i+1) begin : layer1_compression
            FullAdderArray #(.WIDTH(BIT_WIDTH)) fa (
                .a(layer1[3*i]), .b(layer1[3*i+1]), .c_in(layer1[3*i+2]),
                .s(layer2[2*i]), .c_out(layer2[2*i+1])
            );
        end
        // 处理剩余4个部分积（12 - 8 = 4）
        // 前3个压缩为2个，最后1个保留
        FullAdderArray #(.WIDTH(BIT_WIDTH)) fa_remain2 (
            .a(layer1[8]), .b(layer1[9]), .c_in(layer1[10]),
            .s(layer2[8]), .c_out(layer2[9])
        );
        assign layer2[10] = layer1[11];
    endgenerate

    // -------------------- Layer 2 → Layer 3 --------------------
    generate
        // 继续压缩至约6个部分积（代码类似，需补充完整）
        // ...
    endgenerate

    // -------------------- 后续层级（Layer 3→4→5→6） --------------------
    // 每层按类似模式压缩，直至只剩2个部分积

    // -------------------- 最终输出 --------------------
    assign sum  = layer6[0];
    assign carry = layer6[1];
endmodule


module FullAdderArray #(
    parameter WIDTH = 64
)(
    input  [WIDTH-1:0] a, b, c_in,
    output [WIDTH-1:0] s, c_out
);
    // 位并行全加器操作
    genvar i;
    generate
        for (i=0; i<WIDTH; i=i+1) begin : bit_processing
            FullAdder fa (
                .a(a[i]),
                .b(b[i]),
                .c_in(c_in[i]),
                .s(s[i]),
                .c_out(c_out[i])
            );
        end
    endgenerate
endmodule

module FullAdder (
    input  a, b, c_in,
    output s, c_out
);
    assign s = a ^ b ^ c_in;
    assign c_out = (a & b) | (b & c_in) | (a & c_in);
endmodule