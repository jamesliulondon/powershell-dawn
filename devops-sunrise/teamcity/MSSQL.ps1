$deploy_folder = "D:\Deploy"
$url = "https://s3-eu-west-1.amazonaws.com/insight-devops/Binaries/SQLEXPR_x64_ENU.exe"

$mssql_install_file = "SQLEXPR_x64_ENU.exe"
$mssql_install_path = $deploy_folder + "\" + $mssql_install_file
$mssql_exploded_folder = $deploy_folder + "\sql_exploded"

mkdir $deploy_folder -force | Out-Null
mkdir C:\ProgramData\JetBrains\TeamCity\lib\jdbc -force | Out-Null
$clnt = new-object System.Net.WebClient


echo '### Download MSSQL ###'
$clnt.DownloadFile($url,$mssql_install_path)
###iex "& 'C:\tmp\SQLEXPR_x64_ENU.exe' '/q' '/Action=Install' '/Features=SQL,Tools' '/InstanceName=SQLExpress' '/SQLSYSADMINACCOUNTS=Builtin\Administrators'"



$extractCommand="& '$mssql_install_path' '/x:$mssql_exploded_folder' '/q'"
$installCommand = @'
& $mssql_exploded_folder\SETUP.exe /q /ACTION=INSTALL /FEATURES=SQLEngine /INSTANCENAME=SQLEXPRESS /SQLSVCACCOUNT="NT AUTHORITY\SYSTEM" /SECURITYMODE=SQL /SAPWD="P@ssword1" /AGTSVCACCOUNT="NT AUTHORITY\SYSTEM" /TCPENABLED=0 /NPENABLED=1 /IACCEPTSQLSERVERLICENSETERMS /UpdateEnabled="False"
'@

echo '### Unzip MSSQL ###'
iex $extractCommand

echo '### Install MSSQL from extract ###'
iex $installCommand
Start-Sleep -s 20

#echo "# Download SSMS"
# Download SSMS
#$url = "https://s3-eu-west-1.amazonaws.com/insight-devops/Binaries/SQLManagementStudio_x64_ENU.exe"
#$file = "D:\Deploy\SQLManagementStudio_x64_ENU.exe"
#$clnt.DownloadFile($url,$file)
#iex "& 'c:\tmp\SQLManagementStudio_x64_ENU.exe'  '/install' '/quiet' '/norestart'"