# Elasticsearch安装环境准备
## 设置最大文件句柄数、线程数、内存控制
vim /etc/security/limits.conf
```shell
zhonghong soft  memlock  unlimited
zhonghong hard  memlock  unlimited
* soft    nofile  128000
* hard    nofile  128000
* soft    nproc  128000
* hard    nproc  128000
*     soft   nofile   131072
*     hard   nofile   131072
```
## 禁止使用交换内存
vim /etc/fstab<br>
注释掉所要包含"swap"的行
## 虚拟内存大小
* 启动elasticsearch前使用该命令(一次性生效)
sysctl -w vm.max_map_count=262144 
* 永久生效vim /etc/sysctl.conf
```shell
vm.swappiness=1
vm.max_map_count=655360
net.core.somaxconn = 32768
net.ipv4.tcp_retries2=5
```
sysctl vm.max_map_count 检查是否生效
## elasticsearch jvm配置选项 jvm.options(文件)
-Xms20g
-Xmx20g
## 设置es临时目录(此步骤可以跳过)
$ES_TMPDIR /zhonghong/
## 配置文件见elasticsearch.yml
