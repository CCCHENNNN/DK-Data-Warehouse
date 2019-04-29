import os
import re


# aa = "abc des des "
file = open('rj.txt','r')
s = input("Please input a string:")
regex = r"\s.+"
aaa = re.findall(s+regex,file.read())
print(aaa)