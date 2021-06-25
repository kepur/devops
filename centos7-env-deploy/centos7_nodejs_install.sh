#https://nodejs.org/dist/v6.17.1/node-v6.17.1-linux-x64.tar.gz
#https://nodejs.org/dist/v12.20.0/node-v12.20.0.tar.gz
#https://nodejs.org/dist/v12.20.0/node-v12.20.0-linux-x64.tar.gz
#https://nodejs.org/dist/v12.20.0/node-V12.20.0-linux-x64.tar.gz
#https://nodejs.org/dist/v12.20.0/
#https://nodejs.org/dist/v12.20.0/node-v12.20.0-linux-x64.tar.gz
node_root_url='https://nodejs.org/dist'
pkg_dir=/opt/pkg_dir
node_install(){
    if test -z "$(ls | find ~/ -name node && find ~/ -name node_modules | rpm -qa node )"; then
	echo "已安装nodejs 将卸载之前的版本."
        yum remove nodejs npm -y
        rm -rf /usr/local/lib/node*
        rm -rf  /usr/local/include/node*
        rm -rf /usr/local/node*
        rm -rf /usr/local/bin/npm
        rm -rf /usr/local/share/man/man1/node.1
        rm -rf  /usr/local/lib/dtrace/node.d
        rm -rf ~/.npm
        rm -rf /usr/bin/node
        rm -rf /usr/bin/npm
    else
        echo "开始安装nodejs."
    fi
    node_version=$1
	echo $node_version
	nodejs=node-v$node_version-linux-x64.tar.gz
	echo "$nodejs"
	if [ -f "$pkg_dir$nodejs" ];then
		echo " 文件 $nodejs 找到 "
	else
		echo "文件 $nodejs 不存在将自动下载" 
		if ! wget -c -t3 -T60 ${node_root_url}/v$node_version/$nodejs -P $pkg_dir/; then
            echo "Failed to download $nodejs \n 下载$nodejs失败, 请手动下载到${pkg_dir} \n please download it to ${pkg_dir} directory manually and try again."
            echo -e "请把下列安装包放到$pkg_dir目录下 \n\n " $$ sleep 2s
			exit 1
        fi
	fi
    cd $pkg_dir && echo "正在执行Nodejs安装"
	tar -zxvf $nodejs
    mv node-v$node_version-linux-x64 /usr/local/
    ln -s /usr/local/node-v$node_version-linux-x64/bin/node /usr/bin/node
    ln -s /usr/local/node-v$node_version-linux-x64/bin/npm /usr/bin/npm
}

#curl -o- https://jira.mouthmelt.com/centos7-env-deploy/centos7_nodejs_install.sh | bash
function menu_choice {
	clear 
	echo
	echo -e "\t\t. 选择node 安装的版本"
	echo -e "\t1.  node 12.20.0安装"
	echo -e "\t2.  node 13.14.0安装"
	echo -e "\t3.  node 13.4.0安装"
	echo -e "\t4.  node 13.9.0安装"
	echo -e "\t5.  node 14.10.0安装"
	echo -e "\t6.  node 14.6.0安装"
	echo -e "\t7.  node 15.10.0安装"
	echo -e "\t8.  node 15.9.0安装"
	echo -e "\t9.  node 16.4.0安装"
	echo -e "\t0. Exit menu\n\n"
	#-en 选项会去掉末尾的换行符，这让菜单看起来更专业一些
	echo -en "\t\t Enter option:" 
	#read 命令读取用户输入
	read -n 1 choice_version
	}
while [ 1 ]
	do 
		menu_choice
		case $choice_version in
		0)
			break ;;
		1)
			node_install 12.20.0;;
		2)
			node_install 13.14.0;;
		3)
			node_install 13.4.0;;
		4)
			node_install 13.9.0;;
		5)
			node_install 14.10.0;;
		6)
			node_install 14.6.0 ;;
		7)
			node_install 15.10.0;;
		8)
			node_install 15.9.0;;
		9)
			node_install 16.4.0;;
		*)
			clear
			echo "sorry,wrong selection" ;;
		esac
		echo -en "\n\n\t\thit any to contunue"
		read -n 1 line
done
