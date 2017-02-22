# Configuration
$deployDir = "D:\Deploy"
$7zipExe = "C:\Program Files\7-Zip\7z.exe"
$chocoUri = "https://chocolatey.org/install.ps1"

## Tentacle
$tentacleUrl = "https://download.octopusdeploy.com/octopus/Octopus.Tentacle.3.10.1-x64.msi"
$master_key = 'AaHLtYfmrfeXv126g5MEKw=='
$tentacle_exe_path = 'C:\Program Files\Octopus Deploy\Tentacle\Tentacle.exe'


$tentacle_file = %{ $tentacleUrl.split('/')[-1] }

$tentacle_install_path = $deployDir + "\"  + $tentacle_file


echo "### Starting... ###"
clear

echo "### Create deploy directories ###"
mkdir $deployDir -force | Out-Null
$clnt = new-object System.Net.WebClient


echo "### Download Tentacle MSI ###"
$clnt.DownloadFile($tentacleUrl, $tentacle_install_path)


echo "### Choco Install ###"
iwr $chocoUri -UseBasicParsing | iex
choco install -r -y 7zip | Out-Null

echo "### Install Octopus MSI ###"
iex "& 'msiexec.exe' '/i' '$tentacle_install_path' '/passive' '/qr' "| Out-Null
break

echo "### Install Octopus Configure ###"
$octopus_configure_instance = @'
& $tentacle_exe_path create-instance --instance "Tentacle" --config "D:\Octopus\Tentacle.config" --console 
'@
$octopus_configure_newcert = @'
& $tentacle_exe_path new-certificate --instance "Tentacle" --if-blank --console
'@
$octopus_configure_resettrusts = @'
& $tentacle_exe_path configure --instance "Tentacle" --reset-trust --console
'@
$octopus_define_port = @'
& $tentacle_exe_path configure --instance "Tentacle" --home "D:\Octopus" --app "D:\Octopus\Applications" --port "10933" --console
'@
$octopus_configure_newtrusts = @'
& $tentacle_exe_path configure --instance "Tentacle" --trust "D002EA368D87032D0E071A7A385B0EA5CD375388 --console
'@
$octopus_reconfigure_firewall = @'
"netsh" advfirewall firewall add rule "name=Octopus Deploy Tentacle" dir=in action=allow protocol=TCP localport=10933
'@
$octopus_register_apikey = @'
& $tentacle_exe_path register-with --instance "Tentacle" --server "http://YOUR_OCTOPUS" --apiKey="API-YOUR_API_KEY" --role "web-server" --environment "Staging" --comms-style TentaclePassive --console
'@
$octopus_startconsole = @'
& $tentacle_exe_path service --instance "Tentacle" --install --start --console
'@

start-sleep 10

echo "- create-instance"
iex $octopus_configure_instance 
echo "- create-newcerts"
iex $octopus_configure_newcert  
echo "- create-resettrusts"
iex $octopus_configure_resettrusts 
echo "- openport"
iex $octopus_define_port  
echo "- create-newtrust"
iex $octopus_configure_newtrusts  
echo "- create-SA-password"
iex $octopus_reconfigure_firewall  
echo "- reconfigure-firewall"
#iex $octopus_register_apikey  
echo "- create-masterkey"
iex $octopus_startconsole  




#iex "& '$octopus_exe_path' 'service' '/install'"
#iex "& '$octopus_exe_path' 'service' '/start'"


echo "### The End ###"
