# Program:
# program shows the script name ,parameters......
# History:
# 2011/11/28

PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin

export PATH

echo "this program will try to calculate:"
echo "How many days before your demobilization date..."

read -p "please input your demobilization date (YYYYMMDD ex>20110304):" date1

date_d=$(echo $date1 |grep '[0-9]\{8\}')
echo $date_d
if [ "$date_d" = "" ];then
	echo "you input the wrong date format....."
	exit 1
fi

declare -i date_dem=`date --date="$date1" +%s`
declare -i date_now=`date +%s`
declare -i date_total=$(($date_dem-$date_now))
declare -i date_d=$(($date_total/60/60/24))

if [ "$date_d" -lt "0" ];then
	echo "you had been demobilization before :" $((-1*date_d)) "ago"
else
	declare -i date_h=$(($date_total/60/60))
	echo ${date_h}
	echo "you will demobiliation after $date_d days and $date_h hours."
fi
