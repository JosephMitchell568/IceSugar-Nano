# PacifikerClaws FPGA project needs to format BRAM initialization statements
# that are repetitive.
# The goal of this python script is to take care of this repetitive task for
# me so that my hands don't fall off from typing so much XD

number_of_bytes = 0
index = 0

with open(r'PacifikerClaws.mem','r') as f:
 data = f.read()
 lines = data.split()
 for line in lines:
  print("picture_data["+str(index)+"] = 8'h"+line+";");
  index = index + 1

print(number_of_bytes)
