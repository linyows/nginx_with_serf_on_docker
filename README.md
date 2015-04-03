Nginx with Surf on Docker
=========================

It is easy to test NGINX.

Role             | Software
----             | --------
Load Balancer    | Nginx
Web              | Nginx
Web release      | Nginx

monitoring: Supervisor

Setup
-----

boot2docker:

```sh
$ boot2docker init
$ VBoxManage modifyvm "boot2docker-vm" --natpf1 "tcp-port8080,tcp,,8080,,8080"
$ boot2docker start
$ $(boot2docker shellinit)
```

Build images:

```bash
$ docker build -t linyows/lb ./lb
$ docker build -t linyows/web ./web
$ docker build -t linyows/web-release ./web-release
```

Run containers:

```bash
$ docker run -d -t -p 8080:80 -p 7946 --name lb001 linyows/lb
$ docker run -d -t --link lb001:serf --name web001 linyows/web
$ docker run -d -t --link lb001:serf --name web-release001 linyows/web-release
```

Serf Members
------------

```sh
$ docker exec -it lb001 serf members
06fa66004474  172.17.0.15:7946  alive  role=lb
7ad77a816a19  172.17.0.16:7946  alive  role=web
325f9dba4048  172.17.0.17:7946  alive  role=web-release
```

Updated Nginx Conf
--------------------

```sh
$ docker exec -it lb001 cat /etc/nginx/conf.d/web.conf
upstream backend {
    ip_hash;
    health_check interval=3;
    server 172.17.0.16 weight=1;
    server 172.17.0.17 weight=99;
}
```

Apache Bench
------------

1000 requests:

```bash
$ ab -n 1000 -c 10 http://0.0.0.0:8080/
$ docker exec -it web-release001 cat /var/log/nginx/access.log | wc -l
     10
$ docker exec -it web001 cat /var/log/nginx/access.log | wc -l
     990
```

10000 requests:

```bash
$ ab -n 10000 -c 10 http://0.0.0.0:8080/
$ docker exec -it web-release cat /var/log/nginx/access.log | wc -l
     110
$ docker exec -it web cat /var/log/nginx/access.log | wc -l
     10890
```

Reference
---------

https://github.com/hashicorp/serf/tree/master/demo/web-load-balancer
https://github.com/tcnksm-sample/docker-serf-haproxy
http://www.haproxy.org/download/1.6/doc/configuration.txt
