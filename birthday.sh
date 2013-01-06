#!/bin/bash
# Program:
# program shows the script name ,parameters......
# History:
# 2011/11/28

PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin

export PATH

read -p "please input your birthday (ex>20110311):" birth

date_d=$(echo $birth | grep '[0-9]\{8\}')

if [ "$date_d" = "" ];then
	echo "you must input correct your birthday"
	exit 1
fi

declare -i date_birth=$(date --date="$birth" +%s)
echo $date_birth
declare -i date_n=$(date +%s)
echo $date_n
declare -i date_total=$(($date_birth-$date_n))
echo $date_total
declare -i date_d=$(($date_total/60/60/24))
echo $date_d

echo "your birthday will come after $date_d days"
