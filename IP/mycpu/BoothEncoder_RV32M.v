module BoothEncoder_RV32M (
    input  [31:0] multiplicand,
    input  [31:0] multiplier,
    input         is_signed,
    output [63:0] pp [0:16]    // 17个部分积
);
    // 扩展乘数：补1位0，形成33位（用于基4编码）
    wire [32:0] mult_ext = {multiplier, 1'b0};
    
    // 符号处理：根据有符号乘法扩展被乘数
    wire [63:0] multiplicand_ext;
    assign multiplicand_ext = is_signed ? 
        {{32{multiplicand[31]}}, multiplicand} : // 符号扩展
        {32'b0, multiplicand};                   // 无符号扩展

    // 生成17个部分积
    genvar i;
    generate
        for (i=0; i<17; i=i+1) begin : gen_pp
            // 取三元组：mult_ext[2i+2 : 2i]
            wire [2:0] triplet = mult_ext[2*i+2 : 2*i];
            reg [63:0] pp_raw;

            // Booth编码逻辑
            always @(*) begin
                case (triplet)
                    3'b000, 3'b111: pp_raw = 64'b0;            // 0
                    3'b001, 3'b010: pp_raw =  multiplicand_ext << (2*i); // +1X
                    3'b011:         pp_raw =  multiplicand_ext << (2*i +1); // +2X
                    3'b100:         pp_raw = -multiplicand_ext << (2*i +1); // -2X
                    3'b101, 3'b110: pp_raw = -multiplicand_ext << (2*i); // -1X
                    default:        pp_raw = 64'b0;
                endcase
            end

            // 符号扩展至64位
            assign pp[i] = pp_raw;
        end
    endgenerate
endmodule