# Configuration
$deployDir = "D:\Deploy"
$nexus_data_root = "D:\sonatype-work"
$program_file_root = "C:\Program Files"
$7zipExe = "C:\Program Files\7-Zip\7z.exe"
$chocoUri = "https://chocolatey.org/install.ps1"



## Nexus
$nexus_data_backup_url = "https://s3-eu-west-1.amazonaws.com/insight-devops/Nexus/Data.zip"
$nexus_zip_url = "http://download.sonatype.com/nexus/3/nexus-3.0.1-01-win64.zip"
$nexus_config_location = "https://s3-eu-west-1.amazonaws.com/insight-devops/Nexus/nexus.vmoptions"

#$nexus_program_folder = "Nexus"

$nexus_zip_file = %{ $nexus_zip_url.split('/')[-1] }
$nexus_data_backup_file = %{ $nexus_data_backup_url.split('/')[-1] }
$nexus_program_folder = $nexus_zip_file  -replace "-win64.*",""

$nexus_zip_path = $deployDir + "\"  + $nexus_zip_file
$nexus_data_backup_path = $deployDir + "\"  + $nexus_data_backup_file

$nexus_program_folder_path = $program_file_root + "\" + $nexus_program_folder

$nexus_config_path = $nexus_program_folder_path + "\bin\nexus.vmoptions"
$nexus_binary = $nexus_program_folder_path + "\bin\nexus.exe"



echo "### Starting... ###"
clear

write-host $nexus_config_location, $nexus_config_path
write-host $nexus_zip_folder
#break

echo "### Create deploy directories ###"
mkdir $deployDir -force | Out-Null
$clnt = new-object System.Net.WebClient

echo "### Create Program directories ###"
mkdir $nexus_program_folder_path -force | Out-Null
$clnt = new-object System.Net.WebClient

echo "### Create Data directories ###"
mkdir $nexus_data_root -force | Out-Null
$clnt = new-object System.Net.WebClient

echo "### Download Nexus Binaries ###"
$clnt.DownloadFile($nexus_zip_url, $nexus_zip_path) | Out-Null

echo "### Download Nexus DataBackup ###"
#$clnt.DownloadFile($nexus_data_backup_url, $nexus_data_backup_path) | Out-Null

echo "### Choco Install ###"
iwr $chocoUri -UseBasicParsing | iex | Out-Null
choco install -r -y 7zip | Out-Null

echo "### Unzip Nexus Binaries ###"
iex "& '$7zipExe' 'x' '$nexus_zip_path' '-aoa' '-o$program_file_root'" | Out-Null




echo "### Download Nexus Configuration ###"
$clnt.DownloadFile($nexus_config_location, $nexus_config_path) | Out-Null

echo "### Unzip Nexus Data DataBackup ###"
iex "& '$7zipExe' 'x' '$nexus_data_backup_path' '-aoa' '-o$nexus_data_root'" | Out-Null

echo "### Installs Service ###"
iex "& '$nexus_binary' '/install'" | Out-Null

echo "### The End ###"
