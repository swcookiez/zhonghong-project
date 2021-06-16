# 中大用户数据榜单
中山大学项目需求，统计出两个月内热度值前十的用户，并予以展示。相关热度计算详见热度值公式详情表。<br>
## Version<br>
2.0
## 流程介绍<br>
1.使用dubbo消费kafka数据到本地环境<br>
2.flume对接kafka数据，消费数据后写往hdfs<br>
3.使用hive关联hdfs数据<br>
4.hive数据过滤，去重，计算<br>
5.sqoop导出结果至MYSQL<br>
6.spring boot 提供接口前端使用<br>
7.数据展示