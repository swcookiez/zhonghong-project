#!/bin/bash

# 定义变量方便修改
APP=zhongda

# 如果是输入的日期按照取输入日期；如果没输入日期取当前时间的前一天
if [ -n "$1" ] ;then
   do_date=$1
else
   do_date=`date -d "-1 day" +%F`
fi

echo "===日志日期为 $do_date==="
sql="
load data inpath '/zhonghong/flume/ods/zhongda/$do_date/*.snappy' into table "$APP".ods_data partition  (created_day='$do_date');
"

hive -e "$sql"
