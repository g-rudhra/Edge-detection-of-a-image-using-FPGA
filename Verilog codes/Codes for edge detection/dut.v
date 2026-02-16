module Edge_detection(
    input  wire clk,
    input  wire [7:0] p00,p01,p02,
    input  wire [7:0] p10,p11,p12,
    input  wire [7:0] p20,p21,p22,
    output reg  [7:0] edge_out
);
parameter THRESHOLD = 254;
// Use appropriate bit widths
reg signed [10:0] Gx, Gy;  // Max value ±1020
reg [10:0] mag;            // Unsigned for magnitude

always @(posedge clk) begin
    // Sobel Gx
    Gx = (-$signed({1'b0,p00})) + $signed({1'b0,p02})
       + (-2*$signed({1'b0,p10})) + (2*$signed({1'b0,p12}))
       + (-$signed({1'b0,p20})) + $signed({1'b0,p22});
    
    // Sobel Gy
    Gy = (-$signed({1'b0,p00})) + (-2*$signed({1'b0,p01})) + (-$signed({1'b0,p02}))
       + $signed({1'b0,p20}) + (2*$signed({1'b0,p21})) + $signed({1'b0,p22});
    
    // Magnitude approximation
    mag = (Gx[10] ? -Gx : Gx) + (Gy[10] ? -Gy : Gy);

    if (mag > THRESHOLD)
        edge_out <= 8'd255;  // White (edge detected)
    else
        edge_out <= 8'd0;    // Black (no edge)
end
endmodule