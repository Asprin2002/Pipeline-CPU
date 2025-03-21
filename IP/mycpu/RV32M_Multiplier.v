module RV32M_Multiplier (
    input         clk,          // 时钟（用于流水线设计）
    input         rst,          // 复位
    input  [31:0] multiplicand, // 被乘数（rs1）
    input  [31:0] multiplier,   // 乘数（rs2）
    input         is_signed,    // 1=有符号乘法，0=无符号乘法
    input         mul_high,     // 1=取高32位（MULH），0=取低32位（MUL）
    output [31:0] result        // 乘法结果
);
    // -------------------- Booth编码生成部分积 --------------------
    wire [63:0] pp [0:16]; // 17个部分积（64位，符号扩展后）
    BoothEncoder_RV32M booth_enc (
        .multiplicand(multiplicand),
        .multiplier(multiplier),
        .is_signed(is_signed),
        .pp(pp)
    );

    // -------------------- 华莱士树压缩部分积 --------------------
    wire [63:0] sum, carry;
    WallaceTree_32x32 wallace (
        .pp(pp),
        .sum(sum),
        .carry(carry)
    );

    // -------------------- 超前进位加法器（CLA） --------------------
    wire [63:0] product;
    CLA_64bit cla (
        .a(sum),
        .b({carry[62:0], 1'b0}), // 进位左移1位
        .sum(product)
    );
