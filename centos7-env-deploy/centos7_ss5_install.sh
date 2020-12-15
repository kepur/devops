#!/bin/bash
ss53.8.9_install(){
  cd /opt
  if command -v ss5 >/dev/null 2>&1; then
  echo '已经安装 ss5'
  else
  echo '没有安装 ss5 will to install ss5'
  if [ -f '/opt/ss5-3.8.9-6.tar.gz' ]; then
    echo '文件ss5-3.8.9-6.tar.gz已经存在,将进行安装'
    sleep 1s
  else
    echo "文件ss5-3.8.9-6.tar.gz不存在将自动下载"
    wget http://linux-1254084810.file.myqcloud.com/ss5-3.8.9-6.tar.gz || { echo "法下载文件，或下载链接失效请自行下载安装 sshpass";sleep 2s,exit 1; }
  fi
  fi
  echo "安装依赖环境" && yum -y install gcc automake make pam-devel openldap-devel cyrus-sasl-devel
  tar zxvf /opt/ss5-3.8.9-6.tar.gz && cd /opt/ss5-3.8.9
  ./configure && make && make install

  useradd user1 -s /bin/false -p YourPasswordHere
  useradd user1 -s /bin/false -p p@ss1
  iptables -t mangle -A OUTPUT -m owner --uid-owner USER_UID -j MARK --set-mark USER_UID
  iptables -t mangle -A OUTPUT -m owner --uid-owner 501 -j MARK --set-mark 501
  iptables -t nat -A POSTROUTING -m mark --mark 501 -j SNAT --to-source 156.237.179.209
  iptables -nvL -t nat
  iptables -nvL -t mangle
  ss5 -u user1 -b 156.237.179.209:1086
  429683
}
