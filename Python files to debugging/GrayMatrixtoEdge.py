import cv2
import numpy as np
import matplotlib.pyplot as plt

# 1. Read the image (grayscale)
image = np.loadtxt("Gray scale matrix.txt",dtype=np.uint8)  # Load the grayscale matrix from a text file)
# 2. Noise reduction using Gaussian filter
blurred = cv2.GaussianBlur(image, (5, 5), 1.0)

# 3. Sobel gradients in x and y directions
Gx = cv2.Sobel(blurred, cv2.CV_64F, 1, 0, ksize=3)
Gy = cv2.Sobel(blurred, cv2.CV_64F, 0, 1, ksize=3)

# 4. Gradient magnitude
gradient_magnitude = np.sqrt(Gx**2 + Gy**2)

# 5. Normalize to 8-bit range
gradient_magnitude = np.uint8(255 * gradient_magnitude / np.max(gradient_magnitude))

# 6. Thresholding (optional but common)
_, edge_image = cv2.threshold(gradient_magnitude, 50, 255, cv2.THRESH_BINARY)

# 7. Display results
plt.figure(figsize=(12, 4))

plt.subplot(1, 3, 1)
plt.title("Original Image")
plt.imshow(image, cmap='gray')
plt.axis("off")

plt.subplot(1, 3, 2)
plt.title("Sobel Gradient Magnitude")
plt.imshow(gradient_magnitude, cmap='gray')
plt.axis("off")

plt.subplot(1, 3, 3)
plt.title("Final Edge Detected Image")
plt.imshow(edge_image, cmap='gray')
plt.axis("off")

plt.show()