import cv2
import numpy as np
import matplotlib.pyplot as plt

# 1. Read the image (grayscale)
image = np.loadtxt("EdgeOutput.txt",dtype=np.uint8)  # Load the grayscale matrix from a text file)

# 7. Display results
plt.figure()

plt.title("Final Edge Detected Image")
plt.imshow(image, cmap='gray')
plt.axis("off")

plt.show()