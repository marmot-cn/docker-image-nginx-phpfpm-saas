# docker-image-nginx-phpfpm-saas

---

#### 1.0

初始化

#### 1.1

优化fastcgi_buffers

#### 1.2

为接口输出添加`gzip`压缩

#### 1.3

优化nginx配置文件.`nginx.conf`

**worker_processes**

调整为`4`.

		worker_processes  4;

**worker_rlimit_nofile**

指定进程可以打开的最大描述符, 这里在 docker 内部 ulimit -n 是 1048576,这个是docker启动设定的默认值.
我用的 65535 是操作系统的默认值.

		worker_rlimit_nofile 65535;
		
**worker_connections**

调整为`10240`.

这里在生产环境把并发值增高.

##### ab 压力测试

单纯静态文件,不链接phpfpm进行压力测试.这个是在4核环境下进行的测试.


		ab -n 20000 -c 5000

我们统一的请求次数`10000`,每次并发`3000`个进行测试.		
* Concurrency Level: 并发数
* Time taken for tests: 压力测试消耗的总时间
* Complete requests: 压力测试的总次数
* Failed requests: 失败的请求数
* Requests per second: 平均每秒的请求数
* Time per request: 所有并发用户(这里是5000)都请求一次的平均时间
* Time per request(mean, across all concurrent requests): 单个用户请求一次的平均时间
* Transfer rate: 传输速率,单位:KB/s

		
**1.2版本 4核服务器 普通云盘**
	
		Concurrency Level:      5000
		Time taken for tests:   6.540 seconds
		Complete requests:      20000
		Failed requests:        731
		   (Connect: 0, Receive: 0, Length: 731, Exceptions: 0)
		Write errors:           0
		Total transferred:      4489677 bytes
		HTML transferred:       77076 bytes
		Requests per second:    3058.05 [#/sec] (mean)
		Time per request:       1635.029 [ms] (mean)
		Time per request:       0.327 [ms] (mean, across all concurrent requests)
		Transfer rate:          670.39 [Kbytes/sec] received

吞吐率(Requests per second): 3058.05
失败的请求数: 731

**1.3版本 4核服务器 普通云盘**

		Concurrency Level:      5000
		Time taken for tests:   5.388 seconds
		Complete requests:      20000
		Failed requests:        0
		Write errors:           0
		Total transferred:      4660000 bytes
		HTML transferred:       80000 bytes
		Requests per second:    3711.67 [#/sec] (mean)
		Time per request:       1347.102 [ms] (mean)
		Time per request:       0.269 [ms] (mean, across all concurrent requests)
		Transfer rate:          844.55 [Kbytes/sec] received
		
吞吐率(Requests per second):3711.67
失败的请求数: 0

**1.2版本 2核服务器 高效云盘**

		Concurrency Level:      5000
		Time taken for tests:   6.270 seconds
		Complete requests:      20000
		Failed requests:        892
		   (Connect: 0, Receive: 0, Length: 822, Exceptions: 70)
		Write errors:           0
		Total transferred:      4468707 bytes
		HTML transferred:       76716 bytes
		Requests per second:    3189.73 [#/sec] (mean)
		Time per request:       1567.529 [ms] (mean)
		Time per request:       0.314 [ms] (mean, across all concurrent requests)
		Transfer rate:          696.00 [Kbytes/sec] received
		
吞吐率(Requests per second):3189.73
失败的请求数: 892

**1.3版本 2核服务器 高效云盘**

		Concurrency Level:      5000
		Time taken for tests:   5.667 seconds
		Complete requests:      20000
		Failed requests:        0
		Write errors:           0
		Total transferred:      4660000 bytes
		HTML transferred:       80000 bytes
		Requests per second:    3529.20 [#/sec] (mean)
		Time per request:       1416.750 [ms] (mean)
		Time per request:       0.283 [ms] (mean, across all concurrent requests)
		Transfer rate:          803.03 [Kbytes/sec] received
		
吞吐率(Requests per second):3529.20
失败的请求数: 0


#### 1.4

##### fastCGI参数优化

* `fastcgi_connect_timeout`: 指定连接到后端FastCGI的超时时间.
* `fastcgi_send_timeout`: 指定向FastCGI传送请求的超时时间.
* `fastcgi_read_timeout`: 指定接收FastCGI应答的超时时间.这个值是已经完成两次握手后接收FastCGI应答的超时时间

解决`504`超时问题. `504`是`nginx`超时. `502`是`phpfpm`超时.

#### 禁止显示`nginx`版本

`server_tokens off;`

#### 添加安全策略(未更新):

1. 忽略`favicon.ico`
2. 禁止代码文件夹
3. 禁止隐藏文件夹
4. 禁止其他文件
5. 禁止一些底层的具体文件
6. 路由php, 只解析`index.php`
7. 禁止显示nginx版本信息在`nginx.conf`中`server_tokens off;`
8. 修改`client_max_body_size`,因为只在后端做接口传输数据.缩小和`php`限制一样`5MB`

```shell
# 忽略favicon.ico, 不记录日志 
location = /favicon.ico {
    log_not_found off;
    access_log off;
}
# 禁止tests, vendor, conf, database, deployment, Cli, smartfunc, Docs, Application, System
location ~ /(tests|vendor|conf|deployment|Cli|database|Application|System|Docs|smartfunc)/ {
    deny all;
}

# 禁止隐藏文件比如 .git
location ~ /\. {
    deny all;
}

# 禁止所有其他文件
location ~ ^/.*\.(xml|md|json|yml|cache|sh|toml|lock|sql|php) {
    deny all;
}

# 禁止所有具体文件,不区分大小写
location ~* /(smart|VERSION|Dockerfile|EventHandler|Jenkinsfile|marmot) {
   deny all;
}

location = /index.php {
     root           /var/www/html;
 fastcgi_index  index.php;
     fastcgi_pass   phpfpm:9000;
     fastcgi_param  SCRIPT_FILENAME /var/www/html/$fastcgi_script_name;
     include        /etc/nginx/fastcgi_params;
}
```

**废弃, 把框架的`index.php`放到干净的`public`目录下. 同时设定为`nginx`的`root`.这样`nginx`可以更少的禁止不需要访问的文件.

#### 废弃, 不在更新

统一转移为:

* 前端服务层镜像
* 通用服务层镜像
* [后端服务层镜像](https://github.com/chloroplast1983/docker-image-nginx-end)