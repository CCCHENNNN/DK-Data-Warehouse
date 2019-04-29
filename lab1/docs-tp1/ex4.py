import os
import re

file = open('codes_postaux.csv','r+')
fileList = file.readlines() 
for line in fileList:
	# print(line)
	line = re.sub(r'2A', '20', line)
	# print(line)
	file.write(line)
	# matches = re.search(r'2A', line)
	# if matches is not None:
	# 	print(matches)
	# 	line = line.sub()
	# 	print(line)
file.close()