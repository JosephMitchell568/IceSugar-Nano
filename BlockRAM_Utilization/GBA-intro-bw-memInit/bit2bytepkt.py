f = open("GBA-intro-packet.txt","r")
f2 = open("GBA-intro-packet-byte.txt","w")

lines = f.readlines()

count = 1
for line in lines:
 f2.write(line[0])
 if(count == 8):
  f2.write("\n")
  count = 0
 count += 1

f.close()
f2.close()
