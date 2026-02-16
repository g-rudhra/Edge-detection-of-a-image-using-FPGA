
module combined_5x5_Tb;

//////////////////////////////
// Parameters
//////////////////////////////
localparam IMG_h = 738;
localparam IMG_w = 415;
localparam EDGE_THRESHOLD = 60;  // Adjust this value

//////////////////////////////
// Memory Arrays
//////////////////////////////
reg [7:0] original_img  [0:IMG_h-1][0:IMG_w-1];
reg [7:0] blurred_img   [0:IMG_h-1][0:IMG_w-1];
reg [7:0] edge_img      [0:IMG_h-1][0:IMG_w-1];

//////////////////////////////
// File handles and counters
//////////////////////////////
integer file_in, file_out;
integer r, c;
integer edge_count;

//////////////////////////////
// Signals
//////////////////////////////
reg clk;

// 5x5 window for Gaussian blur
reg [7:0] p00, p01, p02, p03, p04;
reg [7:0] p10, p11, p12, p13, p14;
reg [7:0] p20, p21, p22, p23, p24;
reg [7:0] p30, p31, p32, p33, p34;
reg [7:0] p40, p41, p42, p43, p44;

// 3x3 window for edge detection (reusing some signals)
// We'll reassign p00-p22 for edge detection

wire [7:0] GB_out;
wire [7:0] edge_out;

//////////////////////////////
// Helper Function - Get Pixel with Edge Replication
//////////////////////////////
function [7:0] get_pixel;
    input integer row;
    input integer col;
    integer safe_row, safe_col;
    begin
        safe_row = row;
        safe_col = col;
        
        if (safe_row < 0) safe_row = 0;
        if (safe_row >= IMG_h) safe_row = IMG_h - 1;
        if (safe_col < 0) safe_col = 0;
        if (safe_col >= IMG_w) safe_col = IMG_w - 1;
        
        get_pixel = original_img[safe_row][safe_col];
    end
endfunction

function [7:0] get_blurred_pixel;
    input integer row;
    input integer col;
    integer safe_row, safe_col;
    begin
        safe_row = row;
        safe_col = col;
        
        if (safe_row < 0) safe_row = 0;
        if (safe_row >= IMG_h) safe_row = IMG_h - 1;
        if (safe_col < 0) safe_col = 0;
        if (safe_col >= IMG_w) safe_col = IMG_w - 1;
        
        get_blurred_pixel = blurred_img[safe_row][safe_col];
    end
endfunction

//////////////////////////////
// Clock Generation
//////////////////////////////
initial begin
    clk = 0;
    forever #5 clk = ~clk;
end

//////////////////////////////
// Instantiate 5x5 Gaussian Blur
//////////////////////////////
Gaussian_blur_5x5 GB5x5 (
    .clk(clk),
    .p00(p00), .p01(p01), .p02(p02), .p03(p03), .p04(p04),
    .p10(p10), .p11(p11), .p12(p12), .p13(p13), .p14(p14),
    .p20(p20), .p21(p21), .p22(p22), .p23(p23), .p24(p24),
    .p30(p30), .p31(p31), .p32(p32), .p33(p33), .p34(p34),
    .p40(p40), .p41(p41), .p42(p42), .p43(p43), .p44(p44),
    .GB_out(GB_out)
);

//////////////////////////////
// Instantiate Edge Detection
//////////////////////////////
Edge_detection dut (
    .clk(clk),
    .p00(p00), .p01(p01), .p02(p02),
    .p10(p10), .p11(p11), .p12(p12),
    .p20(p20), .p21(p21), .p22(p22),
    .edge_out(edge_out)
);

//////////////////////////////
// Main Test Process
//////////////////////////////
initial begin
    edge_count = 0;
    
    //////////////////////////////
    // STEP 1: Load Original Image
    //////////////////////////////
    $display("[STEP 1] Loading original grayscale image...");
    file_in = $fopen("Gray scale matrix.txt", "r");
    if (file_in == 0) begin
        $display("ERROR: Cannot open 'Gray scale matrix.txt'");
        $finish;
    end
    
    repeat(2) @(posedge clk);
    
    for (r = 0; r < IMG_h; r = r + 1) begin
        for (c = 0; c < IMG_w; c = c + 1) begin
            $fscanf(file_in, "%d", original_img[r][c]);
        end
        if (r % 100 == 0)
            $display("  Loaded row %0d/%0d", r, IMG_h-1);
    end
    $fclose(file_in);
    $display("  ? Image loaded successfully\n");
    
    repeat(5) @(posedge clk);
    
    //////////////////////////////
    // STEP 2: Apply 5x5 Gaussian Blur
    //////////////////////////////
    $display("[STEP 2] Applying 5x5 Gaussian blur...");
    $display("  Kernel size: 5x5");
    $display("  Blur strength: Strong (sigma ? 1.4)");
    
    for (r = 0; r < IMG_h; r = r + 1) begin
        for (c = 0; c < IMG_w; c = c + 1) begin
            // Build 5x5 window with edge replication
            p00 = get_pixel(r-2, c-2);
            p01 = get_pixel(r-2, c-1);
            p02 = get_pixel(r-2, c);
            p03 = get_pixel(r-2, c+1);
            p04 = get_pixel(r-2, c+2);
            
            p10 = get_pixel(r-1, c-2);
            p11 = get_pixel(r-1, c-1);
            p12 = get_pixel(r-1, c);
            p13 = get_pixel(r-1, c+1);
            p14 = get_pixel(r-1, c+2);
            
            p20 = get_pixel(r, c-2);
            p21 = get_pixel(r, c-1);
            p22 = get_pixel(r, c);
            p23 = get_pixel(r, c+1);
            p24 = get_pixel(r, c+2);
            
            p30 = get_pixel(r+1, c-2);
            p31 = get_pixel(r+1, c-1);
            p32 = get_pixel(r+1, c);
            p33 = get_pixel(r+1, c+1);
            p34 = get_pixel(r+1, c+2);
            
            p40 = get_pixel(r+2, c-2);
            p41 = get_pixel(r+2, c-1);
            p42 = get_pixel(r+2, c);
            p43 = get_pixel(r+2, c+1);
            p44 = get_pixel(r+2, c+2);
            
            @(posedge clk);
            #1;
            blurred_img[r][c] = GB_out;
        end
        
        if (r % 50 == 0 || r == IMG_h-1)
            $display("  Blur progress: row %0d/%0d", r, IMG_h-1);
    end
    
    // Save blurred image
    $display("  Writing blurred image to file...");
    file_out = $fopen("Blurred_5x5_Output.txt", "w");
    if (file_out == 0) begin
        $display("ERROR: Cannot create output file");
        $finish;
    end
    
    for (r = 0; r < IMG_h; r = r + 1) begin
        for (c = 0; c < IMG_w; c = c + 1) begin
            $fwrite(file_out, "%d ", blurred_img[r][c]);
        end
        $fwrite(file_out, "\n");
    end
    $fclose(file_out);
    $display("Gaussian blur complete\n");
    
    repeat(5) @(posedge clk);
    
    //////////////////////////////
    // STEP 3: Apply Edge Detection on Blurred Image
    //////////////////////////////
    $display("[STEP 3] Applying Sobel edge detection...");
    $display("  Processing blurred image");
    $display("  Output: Binary (0 or 255)");
    
    for (r = 0; r < IMG_h; r = r + 1) begin
        for (c = 0; c < IMG_w; c = c + 1) begin
            // Build 3x3 window from blurred image
            p00 = get_blurred_pixel(r-1, c-1);
            p01 = get_blurred_pixel(r-1, c);
            p02 = get_blurred_pixel(r-1, c+1);
            
            p10 = get_blurred_pixel(r, c-1);
            p11 = get_blurred_pixel(r, c);
            p12 = get_blurred_pixel(r, c+1);
            
            p20 = get_blurred_pixel(r+1, c-1);
            p21 = get_blurred_pixel(r+1, c);
            p22 = get_blurred_pixel(r+1, c+1);
            
            @(posedge clk);
            #1;
            edge_img[r][c] = edge_out;
            
            // Count edge pixels
            if (edge_out == 255)
                edge_count = edge_count + 1;
        end
        
        if (r % 50 == 0 || r == IMG_h-1)
            $display("  Edge detection progress: row %0d/%0d", r, IMG_h-1);
    end
    
    // Save edge image
    $display("  Writing edge detection output...");
    file_out = $fopen("Edge_Binary_Output.txt", "w");
    if (file_out == 0) begin
        $display("ERROR: Cannot create edge output file");
        $finish;
    end
    
    for (r = 0; r < IMG_h; r = r + 1) begin
        for (c = 0; c < IMG_w; c = c + 1) begin
            $fwrite(file_out, "%d ", edge_img[r][c]);
        end
        $fwrite(file_out, "\n");
    end
    $fclose(file_out);
    $display("  ? Edge detection complete\n");
    
    $finish;
end

endmodule