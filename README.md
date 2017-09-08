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

#### 废弃, 不在更新

统一转移为:

* 前端服务层镜像
* 通用服务层镜像
* [后端服务层镜像](https://github.com/chloroplast1983/docker-image-nginx-end)