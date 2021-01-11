ansible for windows
winrm 
#查看winrm配置
winrm g winrm/config

winrm enumerate winrm/config/listener
winrm quickconfig
winrm e winrm/config/listener
winrm set winrm/config/service/auth @{Basic=“true”}
winrm set winrm/config/service @{AllowUnencrypted=“true”}

https://github.com/ansible/ansible/blob/devel/examples/scripts/ConfigureRemotingForAnsible.ps1

2. Ansible 官方提供初始化脚本
https://github.com/ansible/ansible/blob/devel/examples/scripts/ConfigureRemotingForAnsible.ps1
安装winrm(ansible主机)
pip install “pywinrm>=0.1.1”
编译安装方式:https://pypi.org/project/pywinrm/#files
在windows主机powershell执行:.\Desktop\ConfigureRemotingForAnsible.ps1(上图)
3. 将windows信息写入变量文件
cat group_vars/windows.yml
ansible_user: Administrator
ansible_ssh_pass: Mlxg2234
ansible_ssh_port: 5986
ansible_connection: winrm
ansible_winrm_server_cert_validation: ignore
加密文件:ansible-vault encrypt group_vars/windows.yml
解密文件:ansible-vault decrypt group_vars/windows.yml
关闭windows server防火墙或者开放5986端口
https://zhuanlan.zhihu.com/p/99814357

执行复制文件脚本
ansible icbc_357 -m win_copy -a 'src=/root/change_passwd.bat dest=C:/Users/Administrator/Downloads/change_passwd.bat'

ansible icbc_357 -m win_copy -a 'src=/root/change_passwd.bat dest=C:/Users/Administrator/Downloads'
ansible icbc_357 -m raw -a "cd C:\Users\Administrator\Downloads; cd C:\Users\Administrator\Downloads\change_passwd.bat"
ansible icbc_357 -m raw -a "C:\Users\Administrator\Downloads\Desktop\tscon.bat"
执行exe脚本
ansible windows -m raw -a "cd C:/Users/Administrator/Downloads; C:/Users/Administrator/Downloads/change_passwd.bat"
ansible windows -m raw -a "cd c:\Zabbix3AgentSetup\bin\Debug; c:\Zabbix3AgentSetup\bin\Debug\Zabbix3AgentSetup.exe"


测试文件
ansible -i hosts windows -m win_file -a 'dest=c:\ConfigureRemotingForAnsible.ps1 state=directory' --ask-vault-pass
ansible -i hosts windows -m win_copy -a 'src=/etc/hosts dest=c:\config_dir\hosts.txt’ --ask-vault-pass

删除文件/目录
ansible -i hosts windows -m win_file -a 'dest=c:\config_dir\hosts.txt state=absent' --ask-vault-pass
ansible -i hosts windows -m win_file -a 'dest=c:\config state=absent’ --ask-vault-pass

测试远程执行cmd命令
ansible -i hosts windows -m win_shell -a 'ipconfig' --ask-vault-pass
ansible icbc_357  -m win_shell -a 'ipconfig'


ansible icbc_357  -m win_shell -a 'reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v AutoAdminLogon /t REG_SZ /d 1 /f'
ansible icbc_357  -m win_shell -a 'reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v DefaultUserName /t REG_SZ /d Administrator /f'
ansible icbc_357  -m win_shell -a 'reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v DefaultPassword /t REG_SZ /d "vsfZUGK^x4eFC7gi" /f'
ansible icbc_357  -m win_shell -a 'net user Administrator "vsfZUGK^x4eFC7gi"'



远程重启windows服务器
ansible -i hosts windows -m win_reboot --ask-vault-pass --ask-vault-pass
ansible -i hosts windows -m win_shell -a 'shutdown -r -t 0' --ask-vault-pass
ansible -i hosts windows -m win_shell -a 'shutdown -r -t 0'

测试创建用户(远程在windows客户端上创建用户)
ansible -i hosts windows -m win_user -a “name=test1 passwd=Mlxg2234” --ask-vault-pass

安装iis服务
ansible -i hosts windows -m win_feature -a “name=Web-Server” --ask-vault-pass
ansible -i hosts windows -m win_feature -a “name=Web-Server,Web-Common-Http” --ask-vault-pass

获取iis站点信息
ansible -i hosts -m win_iis_website -a “name=‘Default Web Site’” windows --ask-vault-pass

停止启动IIS站点(started’, ‘restarted’, ‘stopped’ or 'absent)
ansible -i hosts windows -m win_iis_website -a “name=‘Default Web Site’ state=stopped” --ask-vault-pass
ansible -i hosts windows -m win_iis_website -a “name=‘Default Web Site’ state=started” --ask-vault-pass

添加站点
ansible -i hosts windows -m win_iis_website -a “name=acme physical_path=c:\site_test” --ask-vault-pass


安装iis服务
ansible -i hosts windows -m win_feature -a “name=Web-Server” --ask-vault-pass
ansible -i hosts windows -m win_feature -a “name=Web-Server,Web-Common-Http” --ask-vault-pass

获取iis站点信息
ansible -i hosts -m win_iis_website -a “name=‘Default Web Site’” windows --ask-vault-pass

停止启动IIS站点(started’, ‘restarted’, ‘stopped’ or 'absent)
ansible -i hosts windows -m win_iis_website -a “name=‘Default Web Site’ state=stopped” --ask-vault-pass
ansible -i hosts windows -m win_iis_website -a “name=‘Default Web Site’ state=started” --ask-vault-pass

添加站点
ansible -i hosts windows -m win_iis_website -a “name=acme physical_path=c:\site_test” --ask-vault-pass


将windows主机写入hosts文件
[windows]
192.168.20.35 #ansible_ssh_user=“Administrator” —不写变量写入host也行
ansible_ssh_pass=“Mlxg2234” ansible_ssh_port=5986
ansible_connection=“winrm” ansible_winrm_server_cert_validation=ignore

执行命令测试
ansible -i hosts windows -m win_ping --ask-vault-pass（输入windows文件密码）


 wmic /node:47.108.214.184 /user:administrator /password:'''FTCv!_N(=?;fQf!'''  process call create "cmd.exe /c ipconfig >d:\result.txt"

wmic /node:192.168.254.100 /user:hzin /password:hz  process call create "cmd.exe /c ipconfig >d:\result.txt"
WMIcmd.exe -h 192.168.254.100 -d hostname -u hzin -p hz -c "ipconfig"

psexec /accepteula
psexec \\192.168.254.100 -u hzin -p hz cmd.exe

net use \\192.168.254.100\c$ "hz" /user:hzin
pspasswd.exe \\192.168.254.100 -u hzin -p hz hz Aa123.com
cscript psexec.vbs 92.168.254.100 hzin hz "ipconfig"


PS C:\Users\hz> pspasswd.exe \\192.168.254.100 -u hzin -p hz hz Aa123.com

PsPasswd v1.24 - Local and remote password changer
Copyright (C) 2003-2016 Mark Russinovich
Sysinternals - www.sysinternals.com

Error changing password:
RPC 服务器不可用。
PS C:\Users\hz>




net share

C:\Users\hz>net share

共享名       资源                            注解

-------------------------------------------------------------------------------
C$           C:\                             默认共享
D$           D:\                             默认共享
E$           E:\                             默认共享
IPC$                                         远程 IPC
ADMIN$       C:\Windows                      远程管理


net use \\192.168.254.100\ipc$


https://blog.csdn.net/lewky_liu/article/details/78536439

情景三：开启一个新的cmd窗口来运行另一个bat文件
@echo off
echo I am a.bat…
echo now run the b.bat
cd /d D:\test
start “” cmd /k call b.bat
echo over

