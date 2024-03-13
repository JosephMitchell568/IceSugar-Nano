import cv2
import numpy as np

Image = cv2.imread("GBA-intro.jpg")
Image = cv2.resize(Image,(160,80))
Image2 = np.array(Image, copy=True)

white_px = np.asarray([255,255,255])
black_px = np.asarray([0,0,0])

row, col, _ = Image.shape

for r in range(row):
 for c in range(col):
  px = Image[r][c]
  if all(px < white_px - 5):
   Image2[r][c] = black_px

cv2.imwrite("GBA-intro-bw.jpg", Image2)
