
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


==========================================================================
回滚
#!/bin/sh
project=n714
path="/opt/web/devops"
pub=$path"/release/pub/MBOXII/trunk" #发布目录
bak=$path"/release/bak" #生产目录备份文件
prod=$path #生产目录
pub_file_plus=$path"/release/pub_plus.txt" #增量文件：发布包相对生产包的新增文件列表日志

#执行备份
dobak(){
    #删除之前的备份文件（夹）
    for file in $(ls $bak)
    do
        #echo $bak"/"$file
        rm -rf $bak"/"$file
    done
    if [ -f $pub_file_plus ]
    then
        rm -rf $pub_file_plus
    fi
    #将发布目录对应的生产目录的文件（夹）按原结构备份
    function read_dir(){
        for file in `ls $1`
        do
            dir_r=$1"/"$file
            dir_p=${dir_r/#$pub/$prod}
            dir_b=${dir_r/#$pub/$bak}
            if [ -d $dir_r ]  #注意此处之间一定要加上空格，否则会报错
            then
                if [ -d $dir_p ]
                then
                    #echo $dir_b
                    mkdir -p -m 755 $dir_b #创建对应的备份文件夹
                    read_dir $1"/"$file #递归子目录
                else
                    echo $dir_p &>>$pub_file_plus
                fi
            else
                if [ -f $dir_p ]
                then
                    #echo $dir_p" "$dir_b
                    cp $dir_p $dir_b
                else
                    echo $dir_p &>>$pub_file_plus
                fi
            fi
        done
    }
    read_dir $pub
    echo '备份完成'
}

#执行发布
dopub(){
    cp -arf $pub/* $prod
    echo '发布完成'
}

#执行回滚
dorollback(){
    for file in $(cat $pub_file_plus)
    do
        #echo $bak"/"$file
        rm -rf $file
    done
    cp -arf $bak/* $prod
    echo '回滚完成'
}

usage() {
    cat <<EOF
        产品发布脚本使用方法:
        1       备份
        2       发布
        3       回滚
        4       退出
EOF
}

usage
echo '请输入操作指令：'
read cmd
while [ $cmd != 'exit' ]
do
    case $cmd in
        1)
            dobak
            ;;
        2)
            dopub
            ;;
        3)
            dorollback
            ;;
        4)
            #exit
            break
            ;;
        *)
            usage
            ;;
    esac
    echo '请输入操作指令：'
    read cmd
done