import os
#创建inventory
def create_ansible_inventory(windows_username,windows_passwd,ansible_port,ansible_group,server_list_file):
    try:
        clients=[]
        with open(server_list_file, 'r', encoding='utf-8') as f1:
            if os.path.exists("inventory"):
                os.remove('inventory')
            with open('inventory', 'a', encoding='utf-8') as f2:
                f2.write('[{}:vars]\n'.format(ansible_group))
                f2.write('ansible_ssh_user = {}\n'.format(windows_username))
                f2.write('ansible_ssh_pass={}\n'.format(windows_passwd))
                f2.write('ansible_connection=winrm\nansible_winrm_transport: ntlm\n')
                f2.write('ansible_ssh_port = {}\n'.format(ansible_port))
                f2.write('ansible_winrm_server_cert_validation = ignore\n')
                group_name= '[{}]\n'.format(ansible_group)
                f2.write(group_name)
                for data in f1:
                    lines = data.replace('\n', '').split(' ')
                    if lines[0]:
                        name = lines[0]
                    else:
                        continue
                    if lines[1]:
                        ip = lines[1]
                    else:
                        continue
                    client = '''%s ansible_ssh_host=%s\n''' % (name,ip)
                    f2.write(client)
                print('#成功创建inventory')

    except:
        print("请把:{}文件放到当前目录下".format(server_list_file))


#创建并执行playbook
def create_playbook(playbook_name,host_group,batchfile):
    try:
        if os.path.exists("{}-playbook.yml".format(playbook_name)):
            os.remove("{}-playbook.yml".format(playbook_name))
        with open('{}-playbook.yml'.format(playbook_name), 'w', encoding='utf-8') as f3:
            f3.write('---\n- hosts: {}\n'.format(host_group))
            f3.write('  gather_facts: F \n  tasks:\n   - name: 运行脚本\n     script: {}\n'.format(batchfile))
            f3.write('     register: {}\n'.format(playbook_name))
            f3.write('   - debug: var={}\n'.format(playbook_name))
            f3.write('   - name: 查看ip\n     raw : ipconfig\n     register: ipconfig\n')
            f3.write('   - debug : var=ipconfig\n')
        result =os.popen('ansible-playbook {}-playbook.yml -i inventory -vvv'.format(playbook_name))
        res = result.read()
        with open('{}.log'.format(playbook_name),mode='a') as f4:
            print("请查看日志:"'{}.log'.format(playbook_name))
            for loginfo in res.splitlines():
                f4.writelines(loginfo+'\n')
                if 'ok' in loginfo:
                    print("\033[33m{}\033[0m".format(loginfo))

    except Exception as e:
        print('请先创建play-book 和 inventory文件:%s'%e)


if __name__ == "__main__":
    # ansible 192.168.2.2 -m win_copy -a 'src=/etc/hosts dest=D:\\hosts.txt'
    # cmd /k call C:\Users\Administrator\Desktop\abc.bat
    # 卡机IP列表标准文件
    # icbc_345  47.28.129.23

    windows_username = "administrator"  #windows用户名
    windows_passwd = "vsfZUGK^x4eFC7gi" #windows密码
    ansible_port = "5986"               #ansible 端口
    ansible_group = 'windows'           #ansible 组名
    server_list_file = 'iplistfile.txt' #卡机IP列表文件名
    import sys
    try:
        playbook_name = str(sys.argv[1]).split(".")[0]
    except:
        print("请输入要执行的bat文件名:")
        try:
            playbook_name = input().split(".")[0]
        except:
            print('确认bat文件格式:\n 例:change_password.bat')
    print('#创建inventory')
    create_ansible_inventory(windows_username=windows_username, windows_passwd=windows_passwd,
                             ansible_port=ansible_port, ansible_group=ansible_group, server_list_file=server_list_file)
    try:
        print('''#创建并执行playbook\n''')
        create_playbook(playbook_name=playbook_name,host_group=ansible_group,batchfile='{}.bat'.format(playbook_name))
    except:
        print('#尝试手动执行\n 例:#ansible-playbook win-playbook.yml -i inventory')


