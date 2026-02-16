import cv2
import numpy as np
import matplotlib.pyplot as plt

# 1. Read the image (grayscale)
image = cv2.imread("images.jpeg", cv2.IMREAD_GRAYSCALE)
np.savetxt("Gray scale matrix.txt",image, fmt="%d")  # Save the grayscale matrix to a text file
cv2.imwrite("Gray scale image.jpg", image )  # Save the grayscale image to a file

# 2. Noise reduction using Gaussian filter
blurred = cv2.GaussianBlur(image, (5, 5), 1.0)
np.savetxt("Blurred matrix.txt",blurred, fmt="%d")  # Save the blurred matrix to a text file

# 3. Sobel gradients in x and y directions
Gx = cv2.Sobel(blurred, cv2.CV_64F, 1, 0, ksize=3)
Gy = cv2.Sobel(blurred, cv2.CV_64F, 0, 1, ksize=3)

# 4. Gradient magnitude
gradient_magnitude = np.sqrt(Gx**2 + Gy**2)

# 5. Normalize to 8-bit range
gradient_magnitude = np.uint8(255 * gradient_magnitude / np.max(gradient_magnitude))

# 6. Thresholding (optional but common)
_, edge_image = cv2.threshold(gradient_magnitude, 50, 255, cv2.THRESH_BINARY)
cv2.imwrite("Reference Edge detected image.jpg", edge_image )  # Save the edge detected image to a file

# 1. Read the image (grayscale)
image1 = np.loadtxt("EdgeOutput.txt",dtype=np.uint8)  # Load the grayscale matrix from a text file)
image2 = np.loadtxt("Blurred matrix.txt",dtype=np.uint8)  # Load the grayscale matrix from a text file)
cv2.imwrite("Edge detected image.jpg", image1 )  # Save the grayscale image to a file


# 7. Display results
plt.figure(figsize=(12, 4))

plt.subplot(1, 4, 4)

plt.title("Final Edge Detected Image with verilog")
plt.imshow(image1, cmap='gray')
plt.axis("off")


plt.subplot(1, 4, 1)
plt.title("Original Image")
plt.imshow(image2, cmap='gray')
plt.axis("off")

plt.subplot(1, 4, 2)
plt.title("Sobel Gradient Magnitude")
plt.imshow(gradient_magnitude, cmap='gray')
plt.axis("off")

plt.subplot(1, 4, 3)
plt.title("Final Edge Detected Image")
plt.imshow(edge_image, cmap='gray')
plt.axis("off")

plt.show()