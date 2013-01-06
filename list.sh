#!/bin/bash
# Program:
# program shows the script name ,parameters......
# History:
# 2011/11/28

PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin

export PATH

for animal in dog cat elephant
do
	echo "there are ${animal}s..."
done

