#!/bin/bash
#filename:checkStatus.sh
#Version:1.4
#date:2013.02.18
#content:check the status of server
#author:chenbinghui

hostname=`ifconfig eth1 |awk '/inet addr/{print $2}'|cut -f2 -d:`
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
        datetime=`date +"%Y%m%d %H:%M:%S"`
        echo "++++++++++start checkquerylog++++++++"
        echo "$datetime">>$log_file
        echo "hostname:$hostname">>$log_file
}
#此函数是检测当前服务器的系统系能
checkstatus(){
  ###########Check Cpu status##########
  cpuusr=`/usr/bin/sar -u 1 3 |grep Average|awk '{print $3}'`
  cpusys=`/usr/bin/sar -u 1 3 |grep Average|awk '{print $5}'`
  cpusum=`expr $cpuuser+$cpusys |awk -F "." '{print $1}'`
  if [ $cpusum -lt $cpuMax ]
     then
     cpustatus="nice"
  else
     cpustatus="bad"
  fi
  echo "cpustatus is $cpustatus">>$log_file
  ##########check io status##########
  ioUsage=`iostat -x 1 1 |grep '\<sda\>'|awk '{print $12}'|awk -F "." '{print $1}'`
  if [ "$ioUsage" -lt "$ioMax" ]
     then
     iostatus="nice"
  else
     iostatus="bad"
  fi
  echo "iostatus is $iostatus">>$log_file
  ##########check disk status#########
  diskUsage=`df |grep 'data1' |awk '{print $4}'`
  diskUsage=`expr ${diskUsage} / 1024 / 1024`
  if [ "$diskUsage" -lt "$diskMax" ]
     then
     diskstatus="bad"
  elif [ "$diskUsage" -gt "$diskHas" ]
     then
     diskstatus="nice"
  fi
  echo "diskstatus is $diskstatus">>$log_file
 ##########check querylog status#######
  querylogUsage=`ls -l $querylogpath |grep total|awk '{print $2}'`
  querylogUsage=`expr ${querylogUsage} / 1024 / 1024`
  if [ "$querylogUsage" -lt "$querylogMax" ]
     then
     querylogstatus="nice"
  else
     querylogstatus="bad"
  fi
  echo "querlogstatus is $querlogstatus">>$log_file
 ##############check rsync status##############
 #result=1 表示存在rsync进程，result=0 表示不存在rsync进程
 ps -ef |grep 'rsync'|grep -v 'rsync' || result=0 && result=1
 if [ "$result" == 1 ]
    then
    echo "当前有rsync进程存在">> $log_file
 else
    echo "当前的rsync进程空闲，可以进行传输">>$log_file
 fi
}
#此函数是罗列当前目录日志名称
listquery(){
  ls /data1/dbatemp/querylog || sudo mkdir /data1/dbatemp/querylog && cd /data1/dbatemp/querylog
  queryname=`ll -t |grep 'query'|sed '1q'|awk '{print $9}'`
}
#此函数是日志的搬运功能
rsyncquery(){
  if [ "$cpustatus" == "nice" ] && [ "$iostatus" == "nice" ] && [ "$result" == "0" ]
     then
     echo "当前的系统性能不错，可以进行搬运querylog操作" >>$log_file
     ### -n 表示如果为空则返回false，如果不为空返回true
     if [ -n "$queryname" ]
        then
        sudo /usr/bin/rsync --delete-after --password-file=/etc/rsyncd.secrets.passfile -arv $queryname dba@10.73.11.2::data1/general_log/ >>$log_file
     fi
  else
     echo "当前的系统性能不佳，不适合进行querylog操作" >>$log_file
     exit 0;
  fi
}
#此函数是查询日志的切分功能
splitquery(){

  if [ "$diskstatus" == "bad" ]
     then
     echo "当前的磁盘容量不足,需要关闭querylog日志">> $log_file
     $mysql_exec -e "set global general_log=OFF;"
  else
     logstatus=$mysql_exec -e "show variables like 'general%'" |grep '\<general_log\>'|awk '{print $2}'
     if [ "$logstatus" == "ON" ]
        then
        if [ "$querylogstatus" == "bad" ]
           then
           ls /data1/dbatemp/querylog || sudo mkdir /data1/dbatemp/querylog && cd /data1/dbatemp/querylog
           sudo mv $querylogpath /data1/dbatemp/querylog/${hostname}_${time}.log
           $mysql_exec -e "flush logs;"
        fi
     else
        $mysql_exec -e "set global general_log=ON;"
     fi
  fi

}

main(){
  init
  checkstatus
  listquery
  splitquery
  rsyncquery
}

#Main()
Main

