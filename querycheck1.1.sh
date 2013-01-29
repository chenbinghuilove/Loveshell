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
diskHas=10 # service'disk has 10G 
querylogMax=300 # Max query usage 300M
querylogpath="/data1/mysql7999/titan27.log"
mysql_exec="mysqlha_login.sh -P 7999"
null=/dev/null
time=`date +"%Y%m%d_%H%M%S"`


init(){
        log_file="/tmp/querycheck.log"
        datetime=`date +"%Y%m%d %H:%M:%S"
        echo "++++++++++start checkquerylog++++++++"
        echo "$datetime">>$log_file
        echo "hostname:$hostname">>$log_file
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
  echo "cpustatus is $cpustatus">>$log_file
  ##########check io status##########
  ioUsage=`iostat -x 1 1 |grep '\<sda\>'|awk '{print $12}'|awk -F "." '{print $1}'`
  if [ "$ioUsage" -lt "$ioMax" ]
     then
     iostatus=nice
     else 
     iostatus=bad
  fi
  echo "iostatus is $iostatus">>$log_file

  ##########check disk status#########

  diskUsage=`df |grep 'data1' |awk '{print $4}'`
  diskUsage=`expr ${diskUsage} / 1024 / 1024`
  if [ "$diskUsage" -lt "$diskMax" ]
     then
     diskstatus=bad
     elif [ "$diskUsage" -gt "$diskHas" ]
     then     
     diskstatus=nice
  fi
  echo "diskstatus is $diskstatus">>$log_file
 ##########check querylog status#######
  querylogUsage=`ls -l $querylogpath |grep total|awk '{print $2}'`
  querylogUsage=`expr ${querylogUsage} / 1024 / 1024`
  if [ "$querylogUsage" -lt "$querylogMax" ]
     then
     querylogstatus=nice
     else
     querylogstatus=bad
  fi
  echo "querlogstatus is $querlogstatus">>$log_file
 ##############check rsync status##############
 
 ps -ef |grep 'rsync' || result=0 && result=1
 if [ "$result" == 1 ]
    then
    echo "当前有rsync进程存在">> $log_file
    else
    echo "当前的rsync进程空闲，可以进行传输">>$log_file
fi
}

listquery(){
  ls /data1/dbatemp/querylog || sudo mkdir /data1/dbatemp/querylog && cd /data1/dbatemp/querylog
  queryname=`ll -t |grep 'query'|sed '1q'|awk '{print $9}'`
}

rsyncquery(){
  if [ "$cpustatus" == "nice" ] && [ "$iostatus" == "nice" ] && [ "$result" == "0" ]
     then
     echo "当前的系统性能不错，可以进行搬运querylog操作" >>$log_file
     ### -n 表示如果为空则返回false，如果不为空返回true
     if [ -n "$queryname" ]
        then
        sudo /usr/bin/rsync --password-file=/etc/rsyncd.secrets.passfile -arv $queryname dba@10.73.11.210::data1/general_log/
     #####这里还需要检测下是否传输成功。如果成功就删除这个文件，如果不成功就不删除它并写入日志文件。
     
     fi
  else
     echo "当前的系统性能不佳，不适合进行querylog操作" >>$log_file
     exit 0;
  fi
}

splitquery(){
  
  if [ "$diskstatus" == "bad" ]
     then
     echo "当前的磁盘容量不足,需要关闭querylog日志">> $log_file
     $mysqlha_login -e "set global general_log=OFF;"
     rsyncquery()
  else
     logstatus=$mysql_exec -e "show variables like 'general%'" |grep '\<general_log\>'|awk '{print $2}'
     if [ "$logstatus" == "ON" ]
        then
        if [ "$querylogstatus" == "bad" ]
           then
           ls /data1/dbatemp/querylog || sudo mkdir /data1/dbatemp/querylog && cd /data1/dbatemp/querylog
           sudo mv $querylogpath /data1/dbatemp/querylog/${hostname}_${datetime}.log
           $mysqlha_login -e "flush logs;"
           rsyncquery()
        fi
     else
        $mysqlha_login -e "set global general_log=ON;"
     fi
  fi

}

main(){
  init
  checkstatus
  listquery
  rsyncquery
  splitquery
}

#Main()
Main

