mkdir C:\tmp\ -force | Out-Null
mkdir C:\ProgramData\JetBrains\TeamCity\lib\jdbc -force | Out-Null
$clnt = new-object System.Net.WebClient

echo "# Download MSSQL"
# Download MSSQL
#$url = "https://s3-eu-west-1.amazonaws.com/insight-devops/Binaries/SQLEXPR_x64_ENU.exe"
#$file = "c:\tmp\SQLEXPR_x64_ENU.exe"
#$clnt.DownloadFile($url,$file)
###iex "& 'C:\tmp\SQLEXPR_x64_ENU.exe' '/q' '/Action=Install' '/Features=SQL,Tools' '/InstanceName=SQLExpress' '/SQLSYSADMINACCOUNTS=Builtin\Administrators'"

$extractCommand="$ 'D:\Deploy\SQLEXPR_x64_ENU.exe' '/x:D:\tmp2' '/q'"
$unzipCommand = @'
& D:\tmp2\SETUP.exe /q /ACTION=INSTALL /FEATURES=SQLEngine /INSTANCENAME=SQLEXPRESS24/SQLSVCACCOUNT="NT AUTHORITY\SYSTEM" /SECURITYMODE=SQL /SAPWD="P@ssword1" /AGTSVCACCOUNT="NT AUTHORITY\SYSTEM" /TCPENABLED=0 /NPENABLED=1 /IACCEPTSQLSERVERLICENSETERMS /UpdateEnabled="False"
'@
#iex $extractCommand
#iex $unzipCommand

echo "# Download SSMS"
# Download SSMS
$url = "https://s3-eu-west-1.amazonaws.com/insight-devops/Binaries/SQLManagementStudio_x64_ENU.exe"
$file = "D:\Deploy\SQLManagementStudio_x64_ENU.exe"
$clnt.DownloadFile($url,$file)
iex "& 'c:\tmp\SQLManagementStudio_x64_ENU.exe'  '/install' '/quiet' '/norestart'"