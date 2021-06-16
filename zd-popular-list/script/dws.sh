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
insert overwrite table zhongda.dws_data PARTITION (created_day='$do_date')
select
t2.uid,
t2.name,
count(1),
count(1) + sum(t2.grade_all)
from
(select 
t1.uid uid,
t1.name name,
t1.mid mid,
t1.created_at created_at,
t1.grade_all grade_all,
Row_Number() Over(Partition By t1.mid order by t1.created_at desc) rank
from
(select 
get_json_object(json,'$.uid') uid,
get_json_object(json,'$.name') name,
get_json_object(json,'$.grade_all') grade_all,
get_json_object(json,'$.created_at') created_at,
get_json_object(json,'$.mid') mid
from zhongda.ods_data where created_day = '$do_date')t1
)t2
where t2.rank = '1'
group by t2.uid,t2.name;
"

hive -e "$sql"
