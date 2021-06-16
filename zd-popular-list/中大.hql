CREATE EXTERNAL TABLE IF NOT EXISTS zhongda.ods_data(
json String)
partitioned by (created_day string)
STORED AS TEXTFILE TBLPROPERTIES('parquet.compression'='SNAPPY')
;

set hive.execution.engine=mr;
set hive.exec.dynamic.partition.mode=nonstrict;

#建日结果表
CREATE EXTERNAL TABLE IF NOT EXISTS zhongda.dws_data(
uid String,
name String,
article_num BIGINT,
hot_num BIGINT
)
partitioned by (created_day string)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY '\001';
#日结果表导入
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

#建月结果表
CREATE EXTERNAL TABLE IF NOT EXISTS zhongda.ads_data(
uid String,
name String,
article_num BIGINT,
hot_num BIGINT,
created_day String
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY '\001';

insert into table zhongda.ads_data
select
uid,
name,
article_num,
hot_num,
''
from
(select
uid,
name,
sum(article_num) article_num,
sum(hot_num) hot_num
from
zhongda.dws_data
where created_day >= date_add('2021-06-14',-60) and created_day <= '2021-06-14'
group by uid,name)t
order by hot_num desc 
limit 10;

#mysql 建表
CREATE TABLE `zhongda_popular_list` (
  `uid` VARCHAR(255) DEFAULT NULL ,
  `name` VARCHAR(255) CHARACTER SET utf8mb4 DEFAULT NULL ,
  `article_num` BIGINT DEFAULT '0'  ,
  `hot_num` BIGINT DEFAULT '0', 
  `created_day` VARCHAR(255) DEFAULT NULL,
  UNIQUE KEY `uni_id` (uid,created_day)
) ENGINE=INNODB DEFAULT CHARSET=utf8mb4;

sqoop export \
--connect "jdbc:mysql://114.115.209.140:13306/sw_private?useUnicode=true&characterEncoding=utf-8"  \
--username root \
--password  izhonghong@2016root123 \
--table zhongda_popular_list \
--num-mappers 1 \
--export-dir /user/hive/warehouse/zhongda.db/ads_data/ \
--input-fields-terminated-by "\001" \
--update-mode allowinsert \
--update-key "uid,created_day" \
--input-null-string '\\N'    \
--input-null-non-string '\\N';

#数据验证HQL
select
t2.uid,
t2.name,
t2.mid
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
from zhongda.ods_data where created_day = '2021-06-14')t1
)t2
where t2.rank = '1' and t2.uid = 'e9d01014580_null';

select 
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
from zhongda.ods_data where created_day = '2021-06-14')t1
where t1.uid = '225c1004879_'
