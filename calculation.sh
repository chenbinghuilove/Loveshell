#!/bin/bash
# Program:
# program shows the script name ,parameters......
# History:
# 2011/11/28

PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin

export PATH

read -p "please input a number :" n

s=0

for ((i=1;i<=$n;i++))
do
	s=$(($s+$i))
done
echo "the result of $n 's sum is: $s"
