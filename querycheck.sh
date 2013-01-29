#!/bin/bash
#filename:checkStatus.sh
#Version:1.0
#date:2013.01.28
#content:check the status of server
#author:chenbinghui

hostname=`hostname`
cpuMax=80 #Max cpu usage 80%
ioMax=50 #Max io usage 50%
diskMax=5 # Max disk usage 5G
null=/dev/null
time=`date +"%Y%m%d_%H%M%S"`


init(){
        log_file="/tmp/querycheck.log"
        datatime=`date +"%Y%m%d %H:%M:%S"
        echo "++++++++++start checkquerylog++++++++"
        echo "$datatime">>$log_file

}

checkstatus(){
  ###########Check Cpu status##########
  cpuusr=`/usr/bin/sar -u 1 3 |grep Average|awk '{print $3}'`
  cpusys=`/usr/bin/sar -u 1 3 |grep Average|awk '{print $5}'`
  cpusum=`expr $cpuuser+$cpusys |awk -F "." '{print $1}'`
  if [ $cpusum -lt $cpuMax ]
     then
     cpustatus=nice
     else
     cpustatus=bad
  fi



  ##########check io status##########
  ioUsage=`iostat -x 1 1 |grep '\<sda\>'|awk '{print $12}'|awk -F "." '{print $1}'`
  if [ "$ioUsage" -lt "$ioMax" ]
     then
     iostatus=nice
     else 
     iostatus=bad
  fi

  ##########check disk status#########

  diskUsage=`df |grep 'data1' |awk '{print $4}'`
  diskUsage=`expr ${diskUsage} / 1024 / 1024`
  if [ "$diskUsage" -lt "$diskMax" ]
     then
     diskstatus=bad
     else
     diskstatus=nice
  fi
  echo "firsttime:$firsttime"
  echo "secondtime:$secondtime"
  echo "hostname:$hostname"
  echo "diskstatus is $diskstatus"
  echo "cpustatus is $cpustatus"
  echo "iostatus is $iostatus"
}
