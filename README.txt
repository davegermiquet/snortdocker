This branch allows modifications to the network addresses by modifying the ENVIRONMENT .dockerenv file.


Tested on Rocky 9.5 (with selinux in permissive)

Modules needed on host system are the following to get this to work:
[root@localhost daveinspect]# lsmod | grep nft_queue
nft_queue              12288  0
nf_tables             356352  858 nft_queue,nft_ct,nft_compat,nft_reject_inet,nft_fib_ipv6,nft_fib_ipv4,nft_counter,nft_chain_nat,nft_reject,nft_fib,nft_fib_inet
[root@localhost daveinspect]# lsmod | grep filter
iptable_filter         12288  0
ip_tables              32768  1 iptable_filter
[root@localhost daveinspect]#

to enable this modules do the following:

# modprobe iptable_filter
# modprobe nft_queue

Template was some what modified by this person:
https://github.com/jgru/docker-snort3


How to run:

docker compose --env-file .dockerenv up -d

How to test:
docker compose exec snort1 /bin/bash
ping 192.168.56.10 (REJECT)
ping 192.168.56.11 (NO LOG)
ping 192.168.56.12 (LOG)
apt-get upgrade
apt-get install telnet
telnet 192.168.56.13 2223 (REJECT)
telnet 192.168.56.13 2222 (PASS)
