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
set hive.execution.engine=mr;
set hive.exec.dynamic.partition.mode=nonstrict;
insert into table zhongda.ads_data
select
uid,
name,
article_num,
hot_num,
'$do_date'
from
(select
uid,
name,
sum(article_num) article_num,
sum(hot_num) hot_num
from
zhongda.dws_data
where created_day >= date_add('$do_date',-60) and created_day <= '$do_date'
group by uid,name)t
order by hot_num desc 
limit 10;
"

hive -e "$sql"
