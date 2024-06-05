# Image Deblurring Project
# Overview
This project aims to deblur images that have been intentionally blurred. We explore three different mathematical techniques to achieve this: GMRES (Generalized Minimal Residual Method), Tikhonov Regularization, and TSVD (Truncated Singular Value Decomposition). The project involves converting the original image to grayscale, resizing it to a square, blurring it, and then applying the three methods to deblur the image.

# Methods
GMRES (Generalized Minimal Residual Method):
GMRES is an iterative method for solving non-symmetric linear systems. It builds a Krylov subspace to find the solution that minimizes the residual. Key processes include:

- Arnoldi Orthogonalization
- QR Decomposition

Tikhonov Regularization:
This method adds a regularization term to the least squares problem, stabilizing the solutions by controlling error amplification in the presence of noise.

TSVD (Truncated Singular Value Decomposition)
TSVD involves truncating smaller singular values during the singular value decomposition of the blur matrix. It uses Tikhonov to set the truncation level, effectively reducing noise by disregarding components likely to increase errors.

# Implementation
Data Preprocessing:
Convert the original image to grayscale.
Resize the image to a square.
Blur the image using a blur matrix.

Deblurring Techniques:
GMRES: Applied with various error tolerances to deblur the image iteratively.
Tikhonov Regularization: Applied with different alpha values to balance deblurring quality and noise reduction.
TSVD: Applied using Tikhonov values to set truncation levels, improving deblurring by filtering out noise.

# Results
Quantitative data for each method includes computation time, number of iterations, relative residual errors, and 2-norm errors between the deblurred and original images, and between the deblurred and blurred images.

# Comparison
GMRES: Best for high-quality deblurring but computationally expensive.
Tikhonov: Good balance between quality and computational efficiency.
TSVD: Consistent in improving deblurring quality with predictable performance.

# Conclusion
GMRES: Suitable for high-quality deblurring where computational expense is not an issue.
Tikhonov: Practical balance for general use, especially with limited computational resources.
TSVD: Ideal for real-time applications with consistent performance.

# Usage
Clone the repository and run the provided MATLAB scripts to replicate the deblurring process and visualize the results.

<img width="1157" alt="Screenshot 2024-06-05 at 4 45 27 PM" src="https://github.com/Harshithapc99/Image-Deblurring/assets/171514388/27c58e84-c17f-4f07-9013-5bb053071ed6">
