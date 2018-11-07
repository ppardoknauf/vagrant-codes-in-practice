#!/usr/bin/env bash
yum clean all && yum update -y
yum -y install epel-release && yum -y install bash-completion net-tools bind-utils wget telnet vim expect gcc-c++ make jq unzip nfs-utils sshpass
sed -i.bak -e 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
sed -i.bak -e 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config
sed -i.bak -e 's/keepcache=0/keepcache=1/' /etc/yum.conf

systemctl restart sshd
systemctl stop firewalld && sudo systemctl disable firewalld

wget --no-cookies --no-check-certificate --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F; oraclelicense=accept-securebackup-cookie" "http://download.oracle.com/otn-pub/java/jdk/8u191-b12/2787e4a523244c269598db4e85c51e0c/jdk-8u191-linux-x64.rpm"
yum localinstall -y jdk-8u191-linux-x64.rpm

systemctl stop firewalld && sudo systemctl disable firewalld
echo 'export JAVA_HOME=/usr/java/jdk1.8.0_191-amd64/jre' >> ~/.bashrc
echo 'export JAVA_HOME=/usr/java/jdk1.8.0_191-amd64/jre' >> /home/vagrant/.bashrc
