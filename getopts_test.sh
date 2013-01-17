#!/bin/bash
#filename:getopts_test.sh
#date:2013/01/17
#author:chenbinghuilove
#content: test the option about getopts


usage()
{
	echo "usage:getopts_test.sh [option] username";
	echo "eg:getopts_test.sh -a chen";
	echo "eg:getopts_test.sh -a chen -b bing -c hui";
}

while getopts a:b:c:d:f:h OPTION
do
	case "$OPTION" in
	a) echo "your option contain a,with the values is $OPTARG";;
	b) echo "your option has b,with the values is $OPTARG";;
	c) echo "your option has c,with the values is $OPTARG";;
	d) echo "your option has d,with the values is $OPTARG";;
	f) echo "your option has f,with the values is $OPTARG";;
	h) usage ;;
	*) echo "unknown option:$OPTARG";;
	esac
done
