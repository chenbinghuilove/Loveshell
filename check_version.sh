#!/bin/bash
#filename:check_version.sh
#date:2013/01/16
#author:chenbinghuilove

mysql_datadir=/usr/local/mysql
port=3307
version=5.5

plugin=` sudo /bin/ls $mysql_datadir/data${port}/mysql |grep plug -i`

proxies_priv=` sudo /bin/ls $mysql_datadir/data${port}/mysql |grep proxies_priv -i`

if [ -z "$plugin" ] && [ -z "$proxies_priv" ];then
	_version=5.0
elif [ -z "$plugin" ];then
	_version=5.1
else
	_version=5.5
fi


if [ -n "$_version" ];then
	if [ "$_version" != "$version" ];then
		echo -e "\033[1;31;40m Mysql version is $_version.\033[0m"
	fi
	_version=$version
	echo -e "mysql version is $_version"
fi



