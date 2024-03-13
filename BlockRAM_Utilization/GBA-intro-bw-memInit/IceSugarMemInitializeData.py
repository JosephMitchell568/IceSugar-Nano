# PacifikerClaws FPGA project needs to format BRAM initialization statements
# that are repetitive.
# The goal of this python script is to take care of this repetitive task

index = 0

f = open("GBA-intro-packet-byte.txt","r")
f2 = open("GBA-intro-bw-memInit.txt","w")

lines = f.readlines()

string = ""

for line in lines:
 line = line.rstrip()
 string = "memory[%d]=8'b%s;\n" % (index,line)
 f2.write(string)
 index = index + 1
 if(index == 512):
  index = 0 #Reset index back to 0 for RAM block util

f.close()
f2.close()
