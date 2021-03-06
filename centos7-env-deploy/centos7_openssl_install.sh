#!/bin/bash
#https://www.openssl.org/source/openssl-1.1.1k.tar.gz
#https://www.openssl.org/source/openssl-fips-2.0.16.tar.gz
#openssl-3.0.0-alpha17.tar.gz
pkg_dir=/opt/pkg_dir/
openssl_root_url="https://www.openssl.org/source/"
echo " 初始化安装请确保网络通畅DNS解析正常......" && sleep 2s
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
openssl_install(){
    openssl_version=$1
    echo $openssl_version
	openssl=openssl-$openssl_version.tar.gz
	echo "$openssl"
	if [ -f "$pkg_dir$openssl" ];then
		echo " 文件 $openssl 找到 "
	else
		echo "文件 $openssl 不存在将自动下载" 
		if ! wget -c -t3 -T60 ${openssl_root_url}/$openssl -P $pkg_dir/; then
            echo "Failed to download $openssl \n 下载$openssl失败, 请手动下载到${pkg_dir} \n please download it to ${pkg_dir} directory manually and try again."
            echo -e "请把下列安装包放到$pkg_dir目录下 \n\n " $$ sleep 2s
			exit 1
        fi
	fi
    cd $pkg_dir && echo "正在执行Openssl安装"
	tar -zxvf $openssl && cd openssl-$openssl_version
	mkdir -p /usr/local/openssl
	./config --prefix=/usr/local/openssl
	make && make install
	\mv /usr/bin/openssl /usr/bin/openssl.old
	\mv /usr/include/openssl /usr/include/openssl.old
	ln -s /usr/local/openssl/bin/openssl /usr/bin/openssl
	ln -s /usr/local/openssl/include/openssl/ /usr/include/openssl
	echo "/usr/local/openssl/lib/">>/etc/ld.so.conf
	ldconfig
	openssl version -a
}
options=("openssl-3.0.0-alpha17" "openssl-1.1.1k" "openssl-fips-2.0.16" "Quit")
select opt in "${options[@]}"
do
    case $opt in
        "openssl-3.0.0-alpha17")
            echo "you chose install openssl-3.0.0-alpha17" 
            openssl_install 3.0.0-alpha17
            ;;
        "openssl-1.1.1k")
            echo "you chose install openssl-1.1.1k"
			openssl_install 1.1.1k
            ;;
        "openssl-fips-2.0.16")
            echo "you chose install openssl-fips-2.0.16"
			openssl_install fips-2.0.16
            ;;
        "Quit")
            break
            ;;
        *) echo "invalid option ";;
    esac
done

