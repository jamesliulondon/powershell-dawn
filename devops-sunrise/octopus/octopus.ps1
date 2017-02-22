# Configuration
$deployDir = "D:\Deploy"
$7zipExe = "C:\Program Files\7-Zip\7z.exe"
$chocoUri = "https://chocolatey.org/install.ps1"

## Octopus
$octopusUrl = "https://download.octopusdeploy.com/octopus/Octopus.3.8.7-x64.msi"

$octopus_sql_archive_url = "https://s3-eu-west-1.amazonaws.com/insight-devops/Octopus/OctopusDeploy_backup_full_2017_01_30.bak"
$octopus_teamcity_plugin_url = "https://download.octopusdeploy.com/octopus-teamcity/4.5.1/Octopus.TeamCity.zip"
$octopus_tentacle_url =  "https://download.octopusdeploy.com/octopus/Octopus.Tentacle.3.8.7-x64.msi"
$octopus_hydra_package_url = "https://download.octopusdeploy.com/hydra/OctopusDeploy.Hydra.3.8.7.nupkg"

$master_key = 'AaHLtYfmrfeXv126g5MEKw=='
$octopus_exe_path = 'C:\Program Files\Octopus Deploy\Octopus\Octopus.Server.exe'


$octopus_install_file = %{ $octopusUrl.split('/')[-1] }
$octopus_sql_archive_file = %{ $octopus_sql_archive_url.split('/')[-1] }
$octopus_teamcity_plugin_file = %{ $octopus_teamcity_plugin_url.split('/')[-1] }
$octopus_tentacle_file = %{ $octopus_tentacle_url.split('/')[-1] }
$octopus_hydra_package_file = %{ $octopus_hydra_package_url.split('/')[-1] }

$octopus_install_path = $deployDir + "\"  + $octopus_install_file
$octopus_sql_archive_path = $deployDir + "\"  + $octopus_sql_archive_file
$octopus_teamcity_plugin_path = $deployDir + "\"  + $octopus_teamcity_plugin_file
$octopus_tentacle_path = $deployDir + "\"  + $octopus_tentacle_file
$octopus_hydra_package_path = $deployDir + "\"  + $octopus_hydra_package_file


echo "### Starting... ###"
clear

echo "### Create deploy directories ###"
mkdir $deployDir -force | Out-Null
$clnt = new-object System.Net.WebClient


echo "### Download Octopus MSI ###"
$clnt.DownloadFile($octopusUrl, $octopus_install_path)

echo "### Download SQL Archive ###"
#$clnt.DownloadFile($octopus_teamcity_plugin_url, $octopus_sql_archive_path)

echo "### Download TeamCityPlugin ###"
#$clnt.DownloadFile($octopus_teamcity_plugin_url, $octopus_teamcity_plugin_path)

echo "### Download Tentacle ###"
$clnt.DownloadFile($octopus_tentacle_url, $octopus_tentacle_path)


echo "### Choco Install ###"
iwr $chocoUri -UseBasicParsing | iex
choco install -r -y 7zip | Out-Null

echo "### Install Octopus MSI ###"
iex "& 'msiexec.exe' '/i' '$octopus_install_path' '/passive' '/qr' "| Out-Null

echo "### Install Octopus Configure ###"
$octopus_configure_sqlconfigfile = @'
& $octopus_exe_path create-instance --instance "OctopusServer" --config "D:\Octopus\OctopusServer.config"
'@
$octopus_configure_sqlconn = @'
& $octopus_exe_path configure --instance "OctopusServer" --home "D:\Octopus" --storageConnectionString "Data Source=sqlserver;Initial Catalog=OctopusDeploy;Integrated Security=False;UID=sa;Password=P@ssword1" --upgradeCheck "True" --upgradeCheckWithStatistics "True" --webAuthenticationMode "UsernamePassword" --webForceSSL "False" --webListenPrefixes "http://localhost:80/" --commsListenPort "10943" --serverNodeName "sqlserver"
'@


$octopus_configure_grants = @'
& $octopus_exe_path database --instance "OctopusServer" --create --grant "NT AUTHORITY\SYSTEM"
'@
$octopus_sql_stop = @'
& $octopus_exe_path service --instance "OctopusServer" --stop
'@
$octopus_configure_sqlsa = @'
& $octopus_exe_path admin --instance "OctopusServer" --username "admin" --email "admin@admin.com" --password "Sunr1s3!"
'@
$octopus_configure_license = @'
& $octopus_exe_path license --instance "OctopusServer" --licenseBase64 "PExpY2Vuc2UgU2lnbmF0dXJlPSJjQzhGdVhpcTRYb2g0b3lCQ0JHY1AxbkVKdjd5em9jaFExcms1cyt0VlZ2OVJ2c0V0M2hFenhtc1A2YWEyV2JBeWpPTjg5N2FNYkMwNDNqTzh4bU5EQT09Ij4NCiAgPExpY2Vuc2VkVG8+amFtZXM8L0xpY2Vuc2VkVG8+DQogIDxMaWNlbnNlS2V5PjEyNDI0LTYxMjUwLTc3NDI2LTkyMjM1PC9MaWNlbnNlS2V5Pg0KICA8VmVyc2lvbj4yLjA8IS0tIExpY2Vuc2UgU2NoZW1hIFZlcnNpb24gLS0+PC9WZXJzaW9uPg0KICA8VmFsaWRGcm9tPjIwMTctMDItMDc8L1ZhbGlkRnJvbT4NCiAgPFZhbGlkVG8+MjAxNy0wMy0yNDwvVmFsaWRUbz4NCiAgPFByb2plY3RMaW1pdD5VbmxpbWl0ZWQ8L1Byb2plY3RMaW1pdD4NCiAgPE1hY2hpbmVMaW1pdD5VbmxpbWl0ZWQ8L01hY2hpbmVMaW1pdD4NCiAgPFVzZXJMaW1pdD5VbmxpbWl0ZWQ8L1VzZXJMaW1pdD4NCjwvTGljZW5zZT4NCg=="
'@
$octopus_configure_sqlreconf = @'
& $octopus_exe_path service --instance "OctopusServer" --install --reconfigure --start --dependOn "MSSQL$SQLEXPRESS"
'@
$octopus_configure_storagemasterkey = @'
& $octopus_exe_path configure --masterKey=$master_key
'@

start-sleep 10

echo "- create-instance"
iex $octopus_configure_sqlconfigfile | Out-Null
echo "- create-connection"
iex $octopus_configure_sqlconn  | Out-Null
echo "- create-grants"
iex $octopus_configure_grants  | Out-Null
echo "- stop-instance"
iex $octopus_sql_stop  | Out-Null
echo "- create-instance"
iex $octopus_configure_sqlsa  | Out-Null
echo "- create-SA-password"
iex $octopus_configure_license  | Out-Null
echo "- reconfigure-instance"
iex $octopus_configure_sqlreconf  | Out-Null
echo "- create-masterkey"
iex $octopus_configure_storagemasterkey  | Out-Null



Write-Host "Remember to restore the octopusdeploy database."
Write-Host "if you can't reach the SQLSERVER, add a host entry and re-run"

iex "& '$octopus_exe_path' 'service' '/install'"
#iex "& '$octopus_exe_path' 'service' '/start'"


echo "### The End ###"
