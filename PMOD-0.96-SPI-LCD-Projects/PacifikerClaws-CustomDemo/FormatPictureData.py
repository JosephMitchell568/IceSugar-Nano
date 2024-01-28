# PacifikerClaws FPGA project needs to format BRAM initialization statements
# that are repetitive.
# The goal of this python script is to take care of this repetitive task for
# me so that my hands don't fall off from typing so much XD

number_of_bytes = 0
index = 0
n = 0

with open(r'PacifikerClaws.mem','r') as f:
 data = f.read()
 lines = data.split()
 pixels = []
 for n in range(0,len(lines),2):
  print("picture_data["+str(index)+"] = 16'h"+lines[n]+"_"+lines[n+1]+";")
  n = n + 2
  index = index + 1

print(number_of_bytes)
