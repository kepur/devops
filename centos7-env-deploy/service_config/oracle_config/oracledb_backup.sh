#!/bin/sh  
  
export ORACLE_BASE=/opt/oracle/app  
export ORACLE_HOME=$ORACLE_BASE/product/11.2.0/dbhome_1  
export ORACLE_SID=XNGLDB  
export PATH=$PATH:$HOME/bin:$ORACLE_HOME/bin  
  
export DATA_DIR=/opt/oracle/bakdir  
export LOGS_DIR=/opt/oracle/bakdir  
export DELTIME=`date -d "7 days ago" +%Y%m%d`  
export BAKUPTIME=`date +%Y%m%d%H%M%S`  
  
mkdir -p $DATA_DIR  
mkdir -p $LOGS_DIR  
  
echo "Starting bakup..."  
echo "Bakup file path $DATA_DIR/$BAKUPTIME.dmp"  
exp system/Ba.Mei.S88.com file=$DATA_DIR/$BAKUPTIME.dmp log=$LOGS_DIR/$BAKUPTIME.log  
  
echo "Delete the file bakup before 7 days..."  
rm -rf $DATA_DIR/$DELTIME*.dmp  
rm -rf $LOGS_DIR/$DELTIME*.log  
echo "Delete the file bakup successfully. "  
  
echo "Bakup completed."  
