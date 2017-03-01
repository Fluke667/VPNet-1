# VPNet

VPNet(Very Powerful Network Encryption Toolbox) is a modern, open source, strong encryption and easy to use docker image for bypassing the censorship circumvention systems, which helps people gain access to the global internet free of censorship, without knowledge of what is being blocked or the underlying technical.

We believe that the right of visiting free and open global internet is right that all people should enjoy – both technic and the non-technic people.

[![](https://images.microbadger.com/badges/image/acrossfw/vpnet.svg)](https://microbadger.com/images/acrossfw/vpnet "Get your own image badge on microbadger.com")

## Story

**U.S. Consulate request quotation for International Internet access service on Aug 2016.**

> U.S. Consulate General Shanghai  
> Date: Aug 10, 2016  
> To: Prospective Bidders  
> Subject: Request for Quotation for Internet access solution  

![U.S. Consulate Quotation](https://raw.githubusercontent.com/AcrossFW/vpnet/master/image/internet-access-solution-quotation-from-us-consulate-shanghai.jpg)

* [Weibo ScreenShot(original one had already been deleted)](https://raw.githubusercontent.com/AcrossFW/vpnet/master/image/vpn-against-gfw-us-consulate-weibo.jpg)

## Goal

The Goal of VPNet is to satisfy those needs in above story, with the following highlights.

3. All in One
    5. SSH Tunnel
    3. PPTP
    6. Squid Proxy
    1. ShadowSocks
    2. OpenVPN
    4. IPsec
2. Extreme Easy to Setup
    1. Build, Ship, Run with Docker
    2. Compatible with any modern Cloud Hosting Provider(VPS)
    3. One Command for All
1. Professional  
    1. Stable Connection
    2. Strong Encryption
    3. Decentralized

Being an Anti-Censorship Technology, VPNet has to try the best to adapt.

> “Every time censors try a new technique, the tool developers adapt, keeping thousand of users connected to the global internet.”  
>  
>   Malinowski, _Assistant Secretary of State for Democracy, Human Rights and Labor_  

## Quick Start

VPNet is extreme easy to deploy by only one command, because it was built & shiped by docker:

```shell
docker run -d --privileged --net=host acrossfw/vpnet
```

You are set. Cheers!

### Defaults

* user: vpnet
* pass: vpnet.io

Enjoy!


## Out-of-the-box Features

> Sort by standard port number

| Service | Standard Port | VPNet Port | ENV Variables |
|   ---   |      ---      |     ---    |      ---      |
|   SSH   |      22       |   10022    |               |
|   PPTP  |      1723     |    1723    |               |
| ShadowSocks |  8388     |   18388    |               |

_About Port Number: some added 10000 to prevent conflict with host(ONE for all)_

### 1. SSH

TCP: 22

### 2. PPTP

TCP: 1723  
IP: GRE

### 3. Squid

TCP: 3128

### 4. ShadowSocks

TCP: 8388

### 5. IKEv2/IPsec


### 6. OpenVPN

### 7. SSTP

## Cloud Hosting

### 1. System Requirement

The follow requirements is just for suggestion, because VPNet can run in anywhere which has docker installed. If you already have a server, use it as well.

1. Location: Asia(HongKong/Korea/Japan/Singapore)
1. Operation System: 64-bit Debian 8 Jessie
1. CPU/Ram/Disk: Smallest(Cheapest)

### 2. Service Provider

#### :star::star::star::star::star: Great

Tested without any Problem, with best price

1. [DigitalOcean](https://m.do.co/c/9304d9484557) $5/mo, new register user will get $10 free credit
1. [Linode](https://www.linode.com/?r=564ab299ba1b198e0eb12fe0a50d559accaa2300) $10/mo, Tokyo Japan & Singapore, with [$20 COUPON](https://www.google.com/#q=linode+promotion+code+coupon)
1. [Vultr](http://www.vultr.com/?ref=6981349) $5/mo, Tokyo Japan, with [$100 COUPON](http://vultrcouponcode.com/)

#### :star::star::star::star: Good

1. [Amazon Web Service](https://aws.amazon.com/free/) AWS Free Tier includes services for Instance Type _T1.micro_ with a free tier available for 12 months.
1. [Arukas](https://arukas.io) FREE! Japan! Deploy apps right out of the box

#### :star::star::star: So So

Pay by RMB, a little expensive.

1. [阿里云](https://cn.aliyun.com/price/product#/ecs/detail)
1. [腾讯云](https://www.qcloud.com/product/cvm.html)


#### :star::-1: Buggy

Leak of some function

1. [Google Compute Engine](https://cloud.google.com) PPTP not work, because [IP GRE PROTOCOL not supported](https://code.google.com/p/google-compute-engine/issues/detail?id=66)

#### :-1: Not Work

1. TBL

## Docker Installation

Here's how to install docker in 64-bit Debian 8.

```shell
apt-get update && apt-get install apt-transport-https
apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
echo "deb https://apt.dockerproject.org/repo debian-jessie main" > /etc/apt/sources.list.d/docker.list
apt-get update && apt-get install docker-engine
service enable docker
docker run hello-world
```

If you want to install docker for other linux distribution, documents can be found on docker.com at [Install Docker Engine](https://docs.docker.com/engine/installation/#installation).

## Todo

* [ ] [Support KcpTun](http://www.jianshu.com/p/78420fad1481):
  - `url=$(curl -s https://api.github.com/repos/xtaci/kcptun/releases/latest | jq -r '.assets[] | select(.name | contains("linux-amd64")) .browser_download_url')`

## Coding Style

Linting with [ShellCheck](https://github.com/koalaman/shellcheck)

* [Shell Style Guide from Google](https://google.github.io/styleguide/shell.xml) - Use common sense and BE CONSISTENT.

## Reference

* [Getting everything right: baseimage-docker](https://phusion.github.io/baseimage-docker/)
* [Templating with Linux in a Shell Script](http://serverfault.com/a/699377/276381)
* [Best Practices for Writing Bash Script](http://kvz.io/blog/2013/11/21/bash-best-practices/)
* [progrium/bashstyle](https://github.com/progrium/bashstyle)
* [Returning Values from Bash Functions](http://www.linuxjournal.com/content/return-values-bash-functions)
* 
## See Also

1. [Internet Freedom](www.state.gov/e/eb/cip/netfreedom/index.htm) - Our goal is to ensure that any child, born anywhere in the world, has access to the global Internet as an open platform on which to innovate, learn, organize, and express herself free from undue interference or censorship.
1. [US Government Is Investing Millions in Internet Freedom Technologies](motherboard.vice.com/read/why-the-us-government-is-investing-millions-in-internet-freedom-technologies)
1. [The Leading Internet Freedom Technology (LIFT) Initiative: Scaling Up U.S. Leadership to Promote Human Rights Online](https://blogs.state.gov/stories/2015/10/12/leading-internet-freedom-technology-lift-initiative-scaling-us-leadership-promote)

## License

VPNet is licensed under the Apache License, Version 2.0. See LICENSE for the full license text.
