#!/usr/bin/env bash
sudo yum clean all && sudo yum update -y
sudo yum -y install epel-release && sudo yum -y install bash-completion net-tools bind-utils wget telnet vim expect gcc-c++ make jq unzip nfs-utils sshpass
wget --no-cookies --no-check-certificate --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F; oraclelicense=accept-securebackup-cookie" "http://download.oracle.com/otn-pub/java/jdk/8u181-b13/96a7b8442fe848ef90c96a2fad6ed6d1/jdk-8u181-linux-x64.rpm"
sudo yum localinstall -y /home/vagrant/jdk-8u181-linux-x64.rpm
sudo sed -i.bak -e 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
sudo systemctl restart sshd
sudo systemctl stop firewalld && sudo systemctl disable firewalld
sudo echo 'export JAVA_HOME=/usr/java/jre1.8.0_181-amd64/bin/java' >> ~/.bashrc
sudo echo 'export JAVA_HOME=/usr/java/jre1.8.0_181-amd64/bin/java' >> /home/vagrant/.bashrc
sudo sed -i.bak -e 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config
sudo sed -i.bak -e 's/keepcache=0/keepcache=1/' /etc/yum.conf 


sudo useradd -m -d /home/$1 --shell=/sbin/nologin $1
sudo mkdir /etc/$1 && sudo chown -R $1:$1 /etc/$1

if [ "$(hostname)" = "convalc1" -o "$(hostname)" = "convalc2" ]
then
    sudo useradd -m -d /home/$2 --shell=/sbin/nologin $2
    sudo mkdir /etc/$2 && sudo chown -R $2:$2 /etc/$2
fi
