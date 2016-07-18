#!/bin/bash

sdir=$1
echo $sdir

cd $SNIC_TMP

path=/proj/wallner/users/x_sabas/SARAMA-WORKSTATION/SARAMA8/
 
for i in `seq 8`
#	do echo $i
	do 
fn=DIR$i
mkdir $fn/$sdir
mkdir $fn
cd $fn
#	./checkexistNrun.pl &
	$path/checkexistNrun.pl $sdir &
	sleep 1 
cd $SNIC_TMP	
	done
wait
rm -rf $SNIC_TMP/DIR*
