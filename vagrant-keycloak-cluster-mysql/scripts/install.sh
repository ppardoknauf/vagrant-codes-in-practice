#!/usr/bin/env bash

yum clean all && sudo yum update -y
yum -y install epel-release && sudo yum -y install bash-completion net-tools bind-utils wget telnet vim expect gcc-c++ make jq unzip nfs-utils git
sed -i.bak -e 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
systemctl restart sshd
systemctl stop firewalld && sudo systemctl disable firewalld
sed -i.bak -e 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config
sed -i.bak -e 's/keepcache=0/keepcache=1/' /etc/yum.conf
wget --no-cookies --no-check-certificate --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F; oraclelicense=accept-securebackup-cookie" "http://download.oracle.com/otn-pub/java/jdk/8u181-b13/96a7b8442fe848ef90c96a2fad6ed6d1/jdk-8u181-linux-x64.rpm"
yum localinstall -y /home/vagrant/jdk-8u181-linux-x64.rpm
echo 'export JAVA_HOME=/usr/java/jdk1.8.0_181-amd64/jre' >> ~/.bashrc
echo 'export JAVA_HOME=/usr/java/jdk1.8.0_181-amd64/jre' >> /home/vagrant/.bashrc
