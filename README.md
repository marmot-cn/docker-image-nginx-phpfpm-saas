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


