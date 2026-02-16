import numpy as np
import matplotlib.pyplot as plt

# Load grayscale image matrix from text file
img = np.loadtxt("Gray scale matrix.txt", dtype=np.float64)

print("Image shape:", img.shape)
# Sobel kernels
Sx = np.array([[-1, 0, 1],
               [-2, 0, 2],
               [-1, 0, 1]])

Sy = np.array([[-1, -2, -1],
               [ 0,  0,  0],
               [ 1,  2,  1]])


def manual_zero_padding(image, pad_h, pad_w):
    M, N = image.shape

    # Step 1: Create a zero matrix of larger size
    padded = np.zeros((M + 2*pad_h, N + 2*pad_w))

    # Step 2: Copy original image into the center
    padded[pad_h:pad_h+M, pad_w:pad_w+N] = image

    return padded

def convolve2d(image, kernel):
    m, n = image.shape
    km, kn = kernel.shape

    pad_h = km // 2
    pad_w = kn // 2

    # Zero padding
    padded = manual_zero_padding(image, pad_h, pad_w)
    output = np.zeros((m, n))

    # Convolution operation
    for i in range(m):
        for j in range(n):
            region = padded[i:i+km, j:j+kn]
            output[i, j] = np.sum(region * kernel)
    return output

Gx = convolve2d(img, Sx)
Gy = convolve2d(img, Sy)
# Gradient magnitude
edges = np.sqrt(Gx**2 + Gy**2)

# Normalize to 0–255
edges = (edges / edges.max()) * 255
edges = edges.astype(np.uint8)
threshold = 50
edge_binary = np.zeros_like(edges)
edge_binary[edges >= threshold] = 255
plt.figure(figsize=(12,4))

plt.subplot(1,3,1)
plt.title("Input Image (from TXT)")
plt.imshow(img, cmap='gray')
plt.axis("off")

plt.subplot(1,3,2)
plt.title("Gradient Magnitude")
plt.imshow(edges, cmap='gray')
plt.axis("off")

plt.subplot(1,3,3)
plt.title("Final Edge Image")
plt.imshow(edge_binary, cmap='gray')
plt.axis("off")

plt.show()