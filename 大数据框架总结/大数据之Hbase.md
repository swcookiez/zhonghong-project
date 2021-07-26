# 大数据之HBase
## HBase简介
### HBase定义
HBase是一种分布式、可拓展、支持海量数据的NOSQL数据库。
### HBase数据模型
HBase底层物理存储结构（K-V）存储结构，HBase类似一个多维MAP
### 逻辑结构
1. 每行数据都有Rowkey
2. 每行数据都有多个列族，通常只用一个
3. 列族中有多个列
4. 单个列族的数据是存在一个storeFile里的
5. 多条数据组成一个region
### 物理存储结构
1. 数据存在storeFile中，底层是以key-value结构存储<br>
key = rowkey + columnFamily + column + timestamp + type <br>
value = 实际值
2. 不同版本的数据根据timestamp进行区分
### 数据模型
1. name space<br>
命名空间，类似与关系型数据中库的概念，HBase自带两个命名空间hbase、default。<br>
hbase负责hbase内部的一些表<br>
default则表示用户默认使用的命名空间
>关系型数据库：采用了关系模型来组织数据的数据库<br>
关系模型是指二维表格模型，关系型数据库是由多个二维表和之前的联系组成的数据组织<br>
非关系数据库：指非关系型的数据存储系统<br>
### region
类似于关系型数据库中表的概念，不同的是HBase定义表时只需要声明列族，列可以动态添加
### row
HBase表中的每行数据都由一个Rowkey和多个Column组成，数据时按照Rowkey的字典顺序存储的。
### column
HBase每个列都由，列族和列修饰符来确定。
### time stamp
用于表示数据的不同版本，每条数据写入时，如果不指定时间戳，系统就会自动加上该字段，时间为写入时间。
### cell
由{rowkey, column Family：column Qualifier, time Stamp}唯一确定的单元。cell是没有类型的，全部是字节码的形式存贮。
## HBase基本架构
1. HMaster<br>
集群管理者<br>
1)表的管理，创建、删除、修改表信息<br>
2)regionServer管理，分发regions给regionServer。对regionServer进行监控。regions负载均衡和故障转移
2. RegionServer<br>
region的管理者<br>
1)region数据的管理,put\get\delete <br>
2)region的split、compact
3. zookeeper<br>
1)为HMater提供高可用<br>
2)为HMater监控提供辅助<br>
4. HDFS<br>
为HBase提供大数据存储、数据高可用
## 架构原理
数据写入HBase时需要经历如下步骤<br>
1. 将预写入的数据先写入预写日志中，以便容灾恢复
2. 数据落盘前，将数据先放入storeMem中，排序后再写入storeFile中
3. 每个列族为一个store，store有一个memsotre，多个storeFile
## HBase读写流程
写流程<br><br>
1)client向zookeeper请求hbase:meta表所在regionServer<br>
2)向所在regionServer获取hbase:meta表数据，并将表数据缓存<br>
3)通过hbase:meta表获取，所要put数据的region的regionServer<br>
4)请求put数据，regionServer将接收的数据先做预写日志<br>
5)regionServer将数据缓存在memstore<br>
6)regionServer向client返回ack<br>
7)将memstore数据排序后，等达到刷写时机后将数据刷写到storefile，在hdfs以Hfile格式存储<br><br>
读流程<br>
1)client向zookeeper请求hbase:meta表所在regionServer<br>
2)向regionServer获取hbase:meta表数据，并将表数据缓存<br>
3)通过hbase:meta表获取，所要get数据的region的regionServer<br>
4)向block cache、memstore、HFile获取所有数据，并将数据合并，这里的所要指的是不同版本的数据。<br>
5)将在Hfile查询到的数据块缓存到block cache中<br>
6)将合并后的数据返回给client<br>

## HBase compact split
### region compact
region compact分为两种<br>
1. minor compaction,此中合并只会将相邻的hfile进行合并，并行不会删除过期和已经删除的数据
2. major compaction,此种合并会将一个store中所有的Hfile合并成一个HFile，并且会删除过期和已删除数据
### region split
当region的大小达到某个值的时候，region会被切分，吧被切分的region出于负载均衡的考虑可能会分到其他region server

## HBase优化
### 预分区
HBase每个region默认时，只有一个region，所有数据都往这一个region写，有大量数据写时会造成热点region，可以提前预分区，这样写入的region时，不同的rowkey会根据预分区规则写入不同的region，这样可以减少HBase split，和加大HBase并行度，从而提升写入速度。
### HBase写入开启压缩
### 最大文件句柄数
### 内存优化
内存不能调太大，建议16G即可，因为内存过大发生大GC时会导致RegionServer长期处于不可用的状态。