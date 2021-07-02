# elasticsearch配置
## 集群和节点的配置类型
### 动态类型
1.使用API设置或更新正在运行的集群的动态配置。<br>
2.elasticsearch.yml文件配置动态配置<br>
3.使用集群设置API进行更新可以是持久的，适用于集群重新启动，也可以是暂时的，集群重启后失效。可以指定设置一个null应用在动态更新API上，去重置永久或临时设置。

4.相同配置参数优先级(高到底)
>1)临时设置(API)<br>
2)持久设置(API)<br>
3)elasticsearch.yml setting<br>
4)默认配置
### 静态类型
1.静态配置只能配置在elasticsearch.yml文件中，且不能立马生效(需重启集群)。
2.静态配置必须各个节点都需要配置，即各相关节点elasticsearch.yml保持一致
### 详见
[configuration elasticsearch](https://www.elastic.co/guide/en/elasticsearch/reference/7.9/settings.html#cluster-setting-types)
## 集群动态API配置
### 请求方式
>PUT /_cluster/settings
### 描述
使用特殊的请求体，此API调用可以更新就请你设置，更新可以是持久的，也可以是非持久的。<br>
可以通过分配一个NULL值来重置永久或临时设置。如果是重置临时设置，将应用定义的这些值的第一个(即重置后默认优先级配置)
>持久化设置<br>
elasticsearch.yml<br>
默认值
### 查询参数
**flat_settings**<br>
>(可选参数,布尔值)为true则以特定的格式返回设置。默认为false

**include_defaults**
>(可选参数,布尔值)为true则返回集群所有默认配置。默认为false

**master_timeout**
>(可选参数,时间)指定主节点超时连接时间，如果在超时到期之前没有收到响应,这个请求失败且会返回一个错位信息。默认值30秒

**timeout**
>(可选参数,时间)指定请求响应时间，如果在超时到期之前没有收到响应，这个请求失败且返回一个错误信息。默认值30秒
### 请求样例
持久化配置样例
```json
PUT /_cluster/settings
{
    "persistent":{
        "indices.recovery.max_bytes_per_sec":"50mb"
    }
}
```
临时配置样例
```json
PUT /_cluster/settings?flat_settings=true
{
    "transient":{
        "indices.recovery.max_bytes_per_sec" : "20mb"
    }
}
```
响应返回更改的设置，如临时设置更改
```json
PUT /_cluster/settings
{
    "persistent" : { },
    "transient" : {
    "indices.recovery.max_bytes_per_sec" : "20mb"
  }
}
```
重置配置
```json
PUT /_cluster/settings
{
    "transient" : {
    "indices.recovery.max_bytes_per_sec" : null
  }
}
```
响应中不包含已重置的设置
```json
GET /_cluster/settings
{
    "persistent" : {},
    "transient" : {}
  }
}
```
可以使用通配符来来重置配置
```json
PUT /_cluster/settings
{
    "transient" : {"indices.recovery.*":null}
}
```
### 详见
[Cluster update settings API](https://www.elastic.co/guide/en/elasticsearch/reference/7.9/cluster-update-settings.html)

## 断路器(熔断器)配置
Elasticsearch包含多个断路器，elasticsearch使用它们去阻止一些会引发OOM的操作。每个断路器指定一个限定的内存使用。另外，有一个父级断路器指定所有断路器使用内存的总量。<br>
一般来说，这些设置(断路器)可以动态更新，使用集群动态API配置。
### 父断路器
父断路器可应用如下配置
>indices.breaker.total.use_real_memory(静态配置)
>>(true)考虑内存真实的使用情况，(false)仅考虑子断路器预留情况。默认为true。推荐也为true。<br>

>indices.breaker.total.limit(动态配置)
>>父断路器启动限制。<br>
indices.breaker.total.use_real_memory = flase则默认为JVM堆内存的70%<br>
indices.breaker.total.use_real_memory = true则默认为JVM堆内存的95%
### 字段数据断路器
字段数据断路器估算加载字段到字段数据缓存所需堆内存大小，如果加载这个字段将超出字段数据缓存内存限制，字段数据断路器将停止操作且返回一个错误。
>indices.breaker.fielddata.limit(动态配置)
>>触发字段数据断路器限制。默认JVM堆内存40%。根据业务场景可适当调大如60%

>indices.breaker.fielddata.overhead(动态配置)
一个常量，所有字段数据估算都要乘以它来确定最终的估算。默认值1.03
#### 字段数据缓存
如果缓存大小限制被设置，缓存将开始清理掉最近最少更新的数据。此设置能自动避免断路器限制。代价是根据需要重建缓存。
>indices.fielddata.cache.size(静态)
>>字段数据缓存最大值,如38%单节点堆内存或绝对值如12GB。默认是没有限制，如果设置此参数，此参数值需要小于字段断路器限制。