
##服务端
yum install ssh* -y
ssh-keygen -t rsa

ssh-copy-id -i /root/.ssh/id_rsa.pub root@10.25.96.10
ssh-copy-id -i /root/.ssh/id_rsa.pub root@10.25.96.20
ssh-copy-id -i /root/.ssh/id_rsa.pub root@10.25.96.30

配置
[k8scluster:vars]
ansible_ssh_user=root 
ansible_ssh_private_key_file=/root/.ssh/id_rsa
[k8scluster]
master 10.25.96.10
node1 10.25.96.20
node2 10.25.96.30



发布到生产


备份
ansible master -m shell -a "zip -r /opt/web/devops -C /opt"

删除之前的备份文件
开始备份
开始同步
dorsync(){
    
}
dorollback(){
    回滚上一次生产
    删除现有的文件夹
    开始回滚
}