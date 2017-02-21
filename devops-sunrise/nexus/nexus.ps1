# Configuration
$deployDir = "D:\Deploy"
$nexus_data_root = "D:\nexus3data"
$program_file_root = "C:\Program Files"
$7zipExe = "C:\Program Files\7-Zip\7z.exe"
$chocoUri = "https://chocolatey.org/install.ps1"



## Nexus
$nexus_data_backup_url = "https://s3-eu-west-1.amazonaws.com/insight-devops/Nexus/Data.zip"
$nexus_zip_url = "http://download.sonatype.com/nexus/3/nexus-3.0.1-01-win64.zip"
$nexus_config_location = "https://s3-eu-west-1.amazonaws.com/insight-devops/Nexus/nexus.vmoptions"

$nexus_program_folder = "Nexus"
$nexus_data_directory = "sonatype-work"

$nexus_zip_file = %{ $nexus_zip_url.split('/')[-1] }
$nexus_data_backup_file = %{ $nexus_data_backup_url.split('/')[-1] }

$nexus_zip_path = $deployDir + "\"  + $nexus_zip_file
$nexus_data_backup_path = $deployDir + "\"  + $nexus_data_backup_file

$nexus_program_folder_path = $program_file_root + "\" + $nexus_program_folder

$nexus_config_path = $nexus_program_folder_path + "\bin"
$nexus_binary = $nexus_config_path + "\nexus.exe"
$nexus_data_path = $nexus_data_root + "\" + $nexus_data_directory


echo "### Starting... ###"
clear

echo "### Create deploy directories ###"
mkdir $deployDir -force | Out-Null
$clnt = new-object System.Net.WebClient

echo "### Create Program directories ###"
mkdir $nexus_program_folder_path -force | Out-Null
$clnt = new-object System.Net.WebClient

echo "### Create Data directories ###"
mkdir $nexus_data_path -force | Out-Null
$clnt = new-object System.Net.WebClient

echo "### Download Nexus Binaries ###"
$clnt.DownloadFile($nexus_zip_url, $nexus_zip_path) | Out-Null

echo "### Download Nexus ZIP ###"
$clnt.DownloadFile($nexus_data_backup_url, $nexus_data_backup_path) | Out-Null

echo "### Choco Install ###"
iwr $chocoUri -UseBasicParsing | iex | Out-Null
choco install -r -y 7zip | Out-Null

echo "### Unzip Nexus ###"
iex "& '$7zipExe' 'x' '$nexus_zip_path' '-aoa' '-o$program_file_root'" | Out-Null




echo "### Download Nexus Configuration ###"
$clnt.DownloadFile($nexus_config_location, $nexus_config_path) | Out-Null

echo "### Unzip Nexus Data ###"
#iex "& '$7zipExe' 'x' '$nexus_data_backup_path' '-aoa' '-o$nexus_data_path'" | Out-Null

echo "### Installs Service ###"
#iex "& '$nexus_binary' '/install'"

echo "### The End ###"
