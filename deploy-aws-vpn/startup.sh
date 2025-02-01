#!/bin/bash
sudo yum update -y
sudo yum install -y  docker.x86_64
sudo systemctl enable docker
sudo systemctl start docker
docker run -e PASSWORD=wushengguo123 -p 8080:8388 -p 8080:8388/udp -d --restart always shadowsocks/shadowsocks-libev

