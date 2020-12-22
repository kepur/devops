systemctl enable firewalld
systemctl start firewalld
echo "添加防火墙..............."
sleep 1s
firewall-cmd --permanent --zone=public --add-rich-rule="rule family="ipv4"  source address="103.131.206.250/24" port protocol="tcp" port="48456" accept"
firewall-cmd --permanent --zone=public --add-forward-port=port=40928:proto=tcp:toport=8078
firewall-cmd --permanent --zone=public --add-port=8070-8071/tcp
firewall-cmd --permanent --zone=public --add-port=443/tcp
firewall-cmd --permanent --zone=public --add-port=80/tcp
firewall-cmd --permanent --zone=public --add-port=48456/tcp
firewall-cmd --reload

firewall-cmd --permanent --zone=public --remove-port=8080/tcp
firewall-cmd --list-all
firewall-cmd --permanent --zone=public --add-rich-rule="rule family="ipv4"  source address="43.240.15.71" port protocol="tcp" port="8078" accept"
firewall-cmd --permanent --zone=public --add-rich-rule="rule family="ipv4"  source address="103.131.206.250" port protocol="tcp" port="8078" accept"
firewall-cmd --reload

