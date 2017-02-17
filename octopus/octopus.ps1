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
$octopus_hydra_package_file %{ $octopus_hydra_package_url.split('/')[-1] }

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
$clnt.DownloadFile($octopus_teamcity_plugin_url, $octopus_sql_archive_path)

echo "### Download TeamCityPlugin ###"
$clnt.DownloadFile($octopus_teamcity_plugin_url, $octopus_teamcity_plugin_path)

echo "### Download Tentacle ###"
$clnt.DownloadFile($octopus_tentacle_url, $octopus_tentacle_path)

echo "### Download Hydra ###"
$clnt.DownloadFile($octopus_hydra_package_url, $octopus_hydra_package_path)

echo "### Choco Install ###"
iwr $chocoUri -UseBasicParsing | iex
choco install -r -y 7zip | Out-Null

echo "### Install Octopus MSI ###"
iex "& '$msiexec.exe' 'x' '$octopus_install_path'

echo "### Install Octopus Configure ###"
$octopus_configure_commands = @'
& $octopus_exe_path create-instance --instance "OctopusServer" --config "C:\Octopus\OctopusServer.config"
& $octopus_exe_path configure --instance "OctopusServer" --home "D:\Octopus" --storageConnectionString "Data Source=(local)\SQLEXPRESS;Initial Catalog=OctopusDeploy;Integrated Security=True" --upgradeCheck "True" --upgradeCheckWithStatistics "True" --webAuthenticationMode "Domain" --webForceSSL "False" --webListenPrefixes "http://localhost:80/" --commsListenPort "10943" --serverNodeName "W2012.contoso.local"
& $octopus_exe_path database --instance "OctopusServer" --create --grant "NT AUTHORITY\SYSTEM"
& $octopus_exe_path service --instance "OctopusServer" --stop
& $octopus_exe_path admin --instance "OctopusServer" --username "CONTOSO\Administrator" --email "admin@admin.com" --password "P@ssword1"
& $octopus_exe_path license --instance "OctopusServer" --licenseBase64 "PExpY2Vuc2UgU2lnbmF0dXJlPSJjQzhGdVhpcTRYb2g0b3lCQ0JHY1AxbkVKdjd5em9jaFExcms1cyt0VlZ2OVJ2c0V0M2hFenhtc1A2YWEyV2JBeWpPTjg5N2FNYkMwNDNqTzh4bU5EQT09Ij4NCiAgPExpY2Vuc2VkVG8+amFtZXM8L0xpY2Vuc2VkVG8+DQogIDxMaWNlbnNlS2V5PjEyNDI0LTYxMjUwLTc3NDI2LTkyMjM1PC9MaWNlbnNlS2V5Pg0KICA8VmVyc2lvbj4yLjA8IS0tIExpY2Vuc2UgU2NoZW1hIFZlcnNpb24gLS0+PC9WZXJzaW9uPg0KICA8VmFsaWRGcm9tPjIwMTctMDItMDc8L1ZhbGlkRnJvbT4NCiAgPFZhbGlkVG8+MjAxNy0wMy0yNDwvVmFsaWRUbz4NCiAgPFByb2plY3RMaW1pdD5VbmxpbWl0ZWQ8L1Byb2plY3RMaW1pdD4NCiAgPE1hY2hpbmVMaW1pdD5VbmxpbWl0ZWQ8L01hY2hpbmVMaW1pdD4NCiAgPFVzZXJMaW1pdD5VbmxpbWl0ZWQ8L1VzZXJMaW1pdD4NCjwvTGljZW5zZT4NCg=="
& $octopus_exe_path service --instance "OctopusServer" --install --reconfigure --start --dependOn "MSSQL$SQLEXPRESS"
& $octopus_exe_path configure --masterKey=$master_key'
'@
iex $octopus_configure_commands


echo "### The End ###"
