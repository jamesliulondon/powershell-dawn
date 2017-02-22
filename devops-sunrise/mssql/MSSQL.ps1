$deploy_folder = "D:\Deploy"
$urlsql = "https://s3-eu-west-1.amazonaws.com/insight-devops/Binaries/SQLEXPR_x64_ENU.exe"
$urlssms = "https://s3-eu-west-1.amazonaws.com/insight-devops/Binaries/SQLManagementStudio_x64_ENU.exe"

$sqlinstallfile =  %{ $urlsql.split('/')[-1] }
$ssmsinstallfile =  %{ $urlssms.split('/')[-1] }


$mssql_install_path = $deploy_folder + "\" + $sqlinstallfile
$ssms_install_path  = $deploy_folder + "\" + $ssmsinstallfile

$mssql_exploded_folder = $deploy_folder + "\sql_exploded"
$ssms_exploded_folder = $deploy_folder + "\ssms_exploded"
$clnt = new-object System.Net.WebClient


$extractCommandSQL="& '$mssql_install_path' '/x:$mssql_exploded_folder' '/q'"
$installCommandSQL= @'
& $mssql_exploded_folder\SETUP.exe /q /ACTION=INSTALL /FEATURES=SQLEngine /INSTANCENAME=SQLEXPRESS /SQLSVCACCOUNT="NT AUTHORITY\SYSTEM" /SECURITYMODE=SQL /SAPWD="P@ssword1" /AGTSVCACCOUNT="NT AUTHORITY\SYSTEM" /TCPENABLED=1 /NPENABLED=1 /IACCEPTSQLSERVERLICENSETERMS /UpdateEnabled="False"
'@


$extractCommandSSMS="& '$ssms_install_path' '/x:$ssms_exploded_folder' '/q'"
$installCommandSSMS= @'
& $ssms_exploded_folder\SETUP.exe /q /ACTION=INSTALL /FEATURES=TOOLS /INSTANCENAME=SQLEXPRESS /SQLSVCACCOUNT="NT AUTHORITY\SYSTEM" /SECURITYMODE=SQL /SAPWD="P@ssword1" /AGTSVCACCOUNT="NT AUTHORITY\SYSTEM" /TCPENABLED=1 /NPENABLED=1 /IACCEPTSQLSERVERLICENSETERMS /UpdateEnabled="False"
'@

echo '### Download MSSQL ###'
#$clnt.DownloadFile($urlsql,$mssql_install_path) | Out-Null

echo '### Download SSMS ###'
Write-Host $urlssms,$ssms_install_path
$clnt.DownloadFile($urlssms,$ssms_install_path) | Out-Null

echo '### Unzip MSSQL ###'
#iex $extractCommandSQL  | Out-Null

echo '### Unzip SSMS ###'
write-host $extractCommandSSMS
iex $extractCommandSSMS  | Out-Null


echo '### Install SQL from extract ###'
#iex $installCommandSQL  | Out-Null


echo '### Install SSMS from extract ###'
iex $installCommandSSMS  | Out-Null

