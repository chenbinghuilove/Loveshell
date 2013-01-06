#!/bin/bash
# Program:
# program shows the script name ,parameters......
# History:
# 2011/11/28
# author:
# chenbinghuilove

PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin

export PATH

network="10.5.110"
for id in $(seq 220 255)
do 
	ping -c 2 -w 2 ${network}.${id} &>> ./null1 && result=0 || result=1
	
	if [ "$result" == 0 ];then
		echo "server ${network}.${id}端口是不可用"
	else
		echo "server ${network}.${id}端口是可用"
	fi
done


