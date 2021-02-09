卸载软件
@ECHO OFF
FOR /f "tokens=1" %%i in ('reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall" /s /d /f "工行网银助手"^|FINDSTR /i "CurrentVersion"') do (FOR /f "tokens=1-2,*" %%j in ('reg query "%%i" /f "UninstallString"^|FINDSTR /i "UninstallString"') do (CMD /q /c "%%l"))
PAUSE


@ECHO OFF
FOR /f "tokens=1" %%i in ('reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall" /s /d /f "工行网银助手"^|FINDSTR /i "CurrentVersion"') do (FOR /f "tokens=1-2,*" %%j in ('reg query "%%i" /f "UninstallString"^|FINDSTR /i "UninstallString"') do (CMD /q /c "%%l"))
PAUSE

2.注册Get-AppxPackage | Select Name, PackageFullName以获得一个所有已安装程序的列表。按Enter键。对我们来说最重要的字符串是PackageFullName，因为它包含全名

Get-WmiObject -Class Win32_Product -Filter "Name = 'Xftp 6'"

$application = Get-WmiObject -Class Win32_Product -Filter "Name = 'Xftp 6'"
$application.Uninstall()


ansible 使用

- name: Uninstall Tomcat
  win_package:
    path: 'C:\Program Files\Apache Software Foundation\Tomcat 8.0\Uninstall.exe'
    product_id: 'Apache Tomcat 8.0 Tomcat8'
    arguments: '/S -ServiceName="Tomcat8"'
    state: absent