import cv2
import numpy as np

f = open("GBA-intro-packet.txt","w")

Image = cv2.imread("GBA-intro-bw.jpg")
Image2 = np.array(Image, copy=True)

print(len(Image2))


white_px = np.asarray([255,255,255])
black_px = np.asarray([0,0,0])

row, col, _ = Image.shape

counter = 0

for r in range(row):
 for c in range(col):
  px = Image[r][c]
  counter = counter + 1
  if all(px <= 100):
   f.write("0\n")
  if all(px >= 200):
   f.write("1\n")

print(counter)

f.close()
