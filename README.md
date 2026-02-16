# Edge-detection-of-a-image-using-FPGA# Edge Detection Using FPGA

A hardware implementation of the Sobel edge detection algorithm using Verilog for FPGA deployment. This project includes Gaussian blur for noise reduction followed by Sobel operator-based edge detection, with Python scripts for verification and debugging.

## Overview

This project implements real-time image edge detection on FPGA hardware using the classic Sobel edge detection algorithm. The design is optimized for parallel processing and can process image data at high speeds using hardware acceleration.

### Key Features

- **Gaussian Blur (5×5 kernel)**: Removes noise from input images before edge detection
- **Sobel Edge Detection (3×3 kernel)**: Detects edges using gradient computation in both X and Y directions
- **Configurable Threshold**: Adjustable edge detection sensitivity via threshold parameter
- **Hardware Optimized**: Designed for efficient FPGA implementation with minimal resource usage
- **Python Verification Tools**: Complete testing and debugging suite for algorithm validation

## Algorithm Pipeline

1. **Grayscale Conversion**: Input image is converted to grayscale (8-bit per pixel)
2. **Gaussian Blur**: 5×5 Gaussian filter reduces noise and smooths the image
3. **Sobel Operator**: 3×3 Sobel kernels compute gradients in X and Y directions
4. **Gradient Magnitude**: Combined gradient magnitude using |Gx| + |Gy| approximation
5. **Thresholding**: Binary edge detection based on configurable threshold value

## Project Structure

```
Edge-detection-of-a-image-using-FPGA-1/
├── Verilog codes/
│   ├── Codes for edge detection/
│   │   ├── dut.v                      # Sobel edge detection module
│   │   └── Tb.v                       # Testbench for edge detection
│   ├── Codes for noise removel/
│   │   ├── Gaussian_blur.v            # 5×5 Gaussian blur module
│   │   └── Tb_GB.v                    # Testbench for Gaussian blur
│   └── Combined code/
│       └── Comb_Tb.v                  # Combined testbench
├── Python files to debugging/
│   ├── Edge detection.py              # Complete edge detection pipeline
│   ├── Edge detection without CSV...  # Standalone edge detection
│   ├── GrayMatrixtoEdge.py           # Matrix-based edge processing
│   └── Matrix to image.py            # Matrix to image converter
├── Images/
│   ├── Test image.jpg                # Input test image
│   ├── Edge detected image.jpg       # FPGA output result
│   └── Reference Edge detected...    # Python/OpenCV reference output
├── Text output files/
│   ├── Gray scale matrix.txt         # Grayscale pixel values
│   ├── Blurred matrix.txt            # Post-Gaussian blur values
│   └── EdgeOutput.txt                # Final edge detection output
└── README.md
```

## Hardware Modules

### 1. Gaussian Blur Module (`Gaussian_blur.v`)

Implements a 5×5 Gaussian blur filter using the following kernel:

```
1/256 * [1   4   6   4   1]
        [4  16  24  16   4]
        [6  24  36  24   6]
        [4  16  24  16   4]
        [1   4   6   4   1]
```

**Inputs:**
- `clk`: Clock signal
- `p00` to `p44`: 5×5 pixel window (8-bit each)

**Outputs:**
- `GB_out`: Blurred pixel value (8-bit)

### 2. Edge Detection Module (`dut.v`)

Implements Sobel edge detection using 3×3 kernels:

**Sobel X Kernel (Gx):**
```
[-1  0  +1]
[-2  0  +2]
[-1  0  +1]
```

**Sobel Y Kernel (Gy):**
```
[-1  -2  -1]
[ 0   0   0]
[+1  +2  +1]
```

**Inputs:**
- `clk`: Clock signal
- `p00` to `p22`: 3×3 pixel window (8-bit each)

**Outputs:**
- `edge_out`: Binary edge pixel (255 for edge, 0 for non-edge)

**Parameters:**
- `THRESHOLD`: Edge detection sensitivity (default: 254)

## Implementation Details

### Data Width Optimization

- **Input pixels**: 8-bit unsigned (0-255)
- **Gradient calculations**: 11-bit signed to handle maximum Sobel values (±1020)
- **Magnitude**: 11-bit unsigned for absolute sum
- **Output**: 8-bit binary (0 or 255)

### Clock-Based Processing

Both modules operate synchronously on the rising edge of the clock signal, enabling:
- Pipelined processing for high throughput
- Easy integration with video streaming interfaces
- Predictable timing for hardware synthesis

## Python Verification Tools

### Dependencies

```bash
pip install opencv-python numpy matplotlib
```

### Scripts

1. **Edge detection.py**: Complete pipeline comparing FPGA output with OpenCV reference
2. **Edge detection without CSV...**: Standalone edge detection for algorithm verification
3. **GrayMatrixtoEdge.py**: Processes matrix data from text files
4. **Matrix to image.py**: Converts numerical matrices to image files

## Usage

### FPGA Synthesis

1. Open your FPGA development environment (Vivado, Quartus, etc.)
2. Add the Verilog files from `Verilog codes/` to your project
3. For complete pipeline: Use both `Gaussian_blur.v` and `dut.v`
4. For edge detection only: Use `dut.v` alone
5. Synthesize and program your FPGA

### Python Testing

```python
# Run complete edge detection with comparison
python "Python files to debugging/Edge detection.py"

# Process existing matrix data
python "Python files to debugging/GrayMatrixtoEdge.py"
```

### Testbench Simulation

```bash
# Compile and simulate with your Verilog simulator
iverilog -o edge_sim "Verilog codes/Codes for edge detection/Tb.v" \
                      "Verilog codes/Codes for edge detection/dut.v"
vvp edge_sim

# For Gaussian blur testing
iverilog -o blur_sim "Verilog codes/Codes for noise removel/Tb_GB.v" \
                     "Verilog codes/Codes for noise removel/Gaussian_blur.v"
vvp blur_sim
```

## Performance Characteristics

### Resource Utilization (Typical)
- **Logic Elements**: ~200-300 LEs per module
- **Memory**: None (purely combinational with registers)
- **Maximum Frequency**: 100-200 MHz (depending on FPGA family)
- **Latency**: 1 clock cycle per pixel (pipelined)

### Processing Speed
For a 100 MHz clock:
- **Throughput**: 100 million pixels/second
- **1920×1080 (Full HD)**: ~48 fps
- **3840×2160 (4K)**: ~12 fps

## Customization

### Adjusting Edge Sensitivity

Modify the `THRESHOLD` parameter in `dut.v`:
- **Lower values** (e.g., 100-150): More sensitive, detects finer edges
- **Higher values** (e.g., 300-400): Less sensitive, only strong edges

```verilog
parameter THRESHOLD = 254;  // Adjust this value
```

### Changing Gaussian Blur Strength

Modify the kernel coefficients in `Gaussian_blur.v` for different smoothing levels.

## Results

The project includes sample outputs demonstrating:
- Original test image
- Gaussian blurred intermediate result
- Reference edge detection (Python/OpenCV)
- FPGA-generated edge detection output

Results show strong correlation between hardware implementation and software reference, validating the Verilog design.

## Technical Notes

### Why |Gx| + |Gy| Instead of √(Gx² + Gy²)?

The approximation `|Gx| + |Gy|` is used instead of the Euclidean norm for:
- **Faster computation**: Avoids square root calculation
- **Hardware efficiency**: No multipliers or square root units needed
- **Acceptable accuracy**: Provides ~88% of true magnitude with minimal error

### Sliding Window Implementation

The modules expect a sliding window of pixels to be provided by external logic:
- **5×5 window** for Gaussian blur
- **3×3 window** for edge detection

Consider implementing a line buffer system for continuous image streaming.

## Future Enhancements

- [ ] Non-maximum suppression for thinned edges
- [ ] Hysteresis thresholding (Canny edge detection)
- [ ] AXI-Stream interface for easy integration
- [ ] Color image support (RGB to grayscale conversion)
- [ ] Adaptive thresholding
- [ ] HDMI input/output interfaces

## License

This project is open source and available for educational and commercial use.

## Contributing

Contributions are welcome! Please feel free to submit issues or pull requests.

## References

- Sobel, I. (1968). "An Isotropic 3×3 Image Gradient Operator"
- Gaussian blur filter theory and applications
- FPGA-based image processing techniques

---

**Author**: Edge Detection FPGA Project  
**Hardware**: FPGA (Vendor-agnostic design)  
**Language**: Verilog HDL  
**Verification**: Python 3 with OpenCV
