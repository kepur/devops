@ECHO OFF
FOR /f "tokens=1" %%i in ('reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall" /s /d /f "工行网银助手"^|FINDSTR /i "CurrentVersion"') do (FOR /f "tokens=1-2,*" %%j in ('reg query "%%i" /f "UninstallString"^|FINDSTR /i "UninstallString"') do (CMD /q /c "%%l"))
PAUSE