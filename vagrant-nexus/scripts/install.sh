#!/usr/bin/env bash

yum upgrade -y
yum -y install epel-release && yum -y install net-tools bind-utils wget
curl --silent --location https://rpm.nodesource.com/setup_8.x | sudo bash -
yum install -y nodejs && yum install -y gcc-c++ make vim expect telnet strace
npm install pm2 -g && pm2 completion install
sed -i.bak -e 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
sed -i.bak -e 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config
systemctl restart sshd
