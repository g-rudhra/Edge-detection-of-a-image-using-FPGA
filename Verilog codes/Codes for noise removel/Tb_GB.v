module GB_Tb;

localparam IMG_h = 738;
localparam IMG_w = 415;

reg [7:0] image     [0:IMG_h-1][0:IMG_w-1];
reg [7:0] edge_img  [0:IMG_h-1][0:IMG_w-1];
reg [7:0] GB_img  [0:IMG_h-1][0:IMG_w-1];

integer file_in, file_out;
integer r, c;

reg clk;

reg [7:0] p00,p01,p02;
reg [7:0] p10,p11,p12;
reg [7:0] p20,p21,p22;

wire [7:0] GB_out;
function [7:0] get_pixel;
    input integer row, col;
    begin
        // Clamp coordinates to valid range
        if (row < 0) row = 0;
        if (row >= IMG_h) row = IMG_h - 1;
        if (col < 0) col = 0;
        if (col >= IMG_w) col = IMG_w - 1;
        get_pixel = image[row][col];
    end
endfunction

// Then use it:

//////////////////////////////
// Clock generation
//////////////////////////////
initial begin
    clk = 0;
    forever #5 clk = ~clk;
end

//////////////////////////////
// Instantiate DUT
//////////////////////////////
Gaussian_blur GB(
    .clk(clk),
    .p00(p00), .p01(p01), .p02(p02),
    .p10(p10), .p11(p11), .p12(p12),
    .p20(p20), .p21(p21), .p22(p22),
    .GB_out(GB_out)
);
//////////////////////////////
// Simulation
//////////////////////////////
initial begin

    // Open input file
    file_in = $fopen("Gray scale matrix.txt","r");
    if (file_in == 0) begin
        $display("ERROR: Cannot open input file");
        $finish;
    end
    repeat (2) @(posedge clk);
    // Read image
    for (r=0; r<IMG_h; r=r+1)begin
        for (c=0; c<IMG_w; c=c+1)begin
            $fscanf(file_in,"%d", image[r][c]);
        end
    end
    $fclose(file_in);
    repeat(5) @(posedge clk);
    //////////////////////////////
    // Process Image
    //////////////////////////////
    for (r=0; r<IMG_h; r=r+1) begin
        for (c=0; c<IMG_w; c=c+1) begin
            // Set 3x3 window (your existing code)
            p00 = get_pixel(r-1, c-1);
            p01 = get_pixel(r-1, c);
            p02 = get_pixel(r-1, c+1);
            p10 = get_pixel(r, c-1);
            p11 = get_pixel(r, c);
            p12 = get_pixel(r, c+1);
            p20 = get_pixel(r+1, c-1);
            p21 = get_pixel(r+1, c);
            p22 = get_pixel(r+1, c+1);  
            @(negedge clk)
            GB_img[r][c] = GB_out;
        end
        // Light progress
        if (r % 10 == 0 || r == IMG_h-1)
        $display("Row %0d completed", r);
    end
    //////////////////////////////
    // Write Output File
    //////////////////////////////
    file_out = $fopen("GaussianBlurout.txt","w");
    if (file_out == 0) begin
        $display("ERROR: Unable to open output file.");
        $finish;
    end
    $display("File created");
    for (r=0; r<IMG_h; r=r+1) begin
        for (c=0; c<IMG_w; c=c+1)begin
            $fwrite(file_out,"%d ", GB_img[r][c]);
        end
        $fwrite(file_out,"\n");      
    end
    $fclose(file_out);
    $display("Noise removal complete.");
    $finish;
end
endmodule