# zhonghong-project
* 中大项目
* Elasticsearch部署配置
```flow
st=>start: 开始
e=>end: 结束:>http://https://segmentfault.com/blog/ingood
c1=>condition: A
c2=>condition: B
c3=>condition: C
io=>inputoutput: D 
st->c1(no)->e
c2(no)->e
c3(no)->e
c1(yes,right)->c2(yes,right)->c3(yes,right)->io
io->e
```
