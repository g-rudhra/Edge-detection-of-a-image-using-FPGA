`timescale 1ns / 1ps

module Gaussian_blur_5x5(
    input  wire clk,
    input  wire [7:0] p00, p01, p02, p03, p04,
    input  wire [7:0] p10, p11, p12, p13, p14,
    input  wire [7:0] p20, p21, p22, p23, p24,
    input  wire [7:0] p30, p31, p32, p33, p34,
    input  wire [7:0] p40, p41, p42, p43, p44,
    output reg  [7:0] GB_out
);

reg [15:0] sum;

always @(posedge clk) begin
    sum = // Row 0
          (1*p00) + (4*p01) + (6*p02) + (4*p03) + (1*p04)
          // Row 1
        + (4*p10) + (16*p11) + (24*p12) + (16*p13) + (4*p14)
          // Row 2
        + (6*p20) + (24*p21) + (36*p22) + (24*p23) + (6*p24)
          // Row 3
        + (4*p30) + (16*p31) + (24*p32) + (16*p33) + (4*p34)
          // Row 4
        + (1*p40) + (4*p41) + (6*p42) + (4*p43) + (1*p44);
    
    // Divide by 256 (right shift by 8)
    GB_out <= sum[15:8];
end

endmodule