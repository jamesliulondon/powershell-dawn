# Configuration
$deployDir = "D:\Deploy"
$7zipExe = "C:\Program Files\7-Zip\7z.exe"
$chocoUri = "https://chocolatey.org/install.ps1"

## TeamCity
$teamCityUri = "https://download.jetbrains.com/teamcity/TeamCity-10.0.1.tar.gz"
$teamCityPackage = "TeamCity"
$teamCityTarballGZipped = $teamCityPackage + ".tar.gz"
$teamCityTarball = $teamCityPackage + ".tar"
$teamCityOriginPath = $deployDir + "\" + $teamCityTarballGZipped
$teamCityInstallDir = "C:\Program Files\TeamCity"
$teamCityOriginDir = $deployDir + "\TeamCity\"
$teamCityTarOriginPath = $deployDir + "\" + $teamCityTarball
$teamCityMaintainDBCmd = $teamCityInstallDir + "\" + "\bin\maintainDB.cmd"
$teamCityDataDir = "C:\ProgramData\JetBrains\TeamCity"

## sqlJDBC
$sqlJBDCUri = "https://s3-eu-west-1.amazonaws.com/insight-devops/Binaries/sqljdbc_6.0.8112.100_enu.tar.gz"
$sqlJBDCPackage = "sqljdbc"
$sqlJBDCTarball = $sqlJBDCPackage + ".tar"
$sqlJBDCTarballGZipped = $sqlJBDCPackage + ".tar.gz"
$sqlJBDCOriginPath = $deployDir + "\" + $sqlJBDCTarballGZipped
$sqlJDBCTarOriginPath = $deployDir + "\" + $sqlJBDCTarball
$sqlJBDCInstallDir = $teamCityDataDir + "\lib\jdbc"
$sqlJDBCJar = $deployDir + "\" + "sqljdbc_6.0\enu\jre8\sqljdbc42.jar"

## Artifacts
$artifactsUri = "https://s3-eu-west-1.amazonaws.com/insight-devops/TeamCity/TeamCityDataDirectory.zip" 
$artifactsZip = "TeamCityDataDirectory.zip"
$artifactsOriginPath = $deployDir + "\" + $artifactsZip
$artifactsSrcDir = $deployDir + "\" + "TeamCityDataDirectory\TeamCity\system\artifacts"
$artifactsDestDir = $teamCityDataDir + "\" + "system\artifacts"


## Database Config
$dbBackupUri = 'https://s3-eu-west-1.amazonaws.com/insight-devops/TeamCity/TeamCity_Backup_Custom_20170206_091513.zip'
$dbBackupFile = 'TeamCity_Backup_Custom_20170206_091513.zip'
$dbConfigUri = "https://s3-eu-west-1.amazonaws.com/insight-devops/TeamCity/database.properties"
$dbConfigFile = "database.properties"
$dbConfigOriginPath = $deployDir + "\" + $dbConfigFile
$dbBackupOriginPath = $deployDir + "\" + $dbBackupFile

$datatar_untar_command = @'
$7zipExe x $teamCityTarOriginPath -aoa -o$deployDir
'@



echo "### Starting... ###"
clear

echo "### Create deploy directories ###"
mkdir $deployDir -force | Out-Null

$clnt = new-object System.Net.WebClient

echo "### Download TeamCity ###"
$clnt.DownloadFile($teamCityUri, $teamCityOriginPath)

echo "### Download sqljdbc ###"
$clnt.DownloadFile($sqlJBDCUri, $sqlJBDCOriginPath)

echo "### Download sqljdbc ###"
$clnt.DownloadFile($dbBackupUri, $dbBackupOriginPath)

echo "### Download Artifacts ###"
$clnt.DownloadFile($artifactsUri, $artifactsOriginPath)

echo "### Download DB Config ###"
$clnt.DownloadFile($dbConfigUri, $dbConfigOriginPath)

echo "### Choco Install ###"
iwr $chocoUri -UseBasicParsing | iex
choco install -r -y 7zip | Out-Null

echo "### Untar and Move TeamCity ###"
echo "### - GUNZIP ###"
iex "& '$7zipExe' 'x' '$teamCityOriginPath' '-aoa' '-o$deployDir'" | Out-Null
echo "### - UNTAR ###"
iex "& '$7zipExe' 'x' '$teamCityTarOriginPath' '-aoa' '-o$deployDir'" | Out-Null
echo "### - MOVE ###"
mv "$teamCityOriginDir" "$teamCityInstallDir" -Force | Out-Null


echo "### Untar and Copy JDBC ###"
iex "& '$7zipExe' 'x' '$sqlJBDCOriginPath' '-aoa' '-o$deployDir'" | Out-Null
iex "& '$7zipExe' 'x' '$sqlJDBCTarOriginPath' '-aoa' '-o$deployDir'" | Out-Null
New-Item -ItemType Directory -Path "$sqlJBDCInstallDir" -Force | Out-Null
cp "$sqlJDBCJar" "$sqlJBDCInstallDir" | Out-Null

echo "### SyncDB ###"
iex "& 'echo' '$teamCityMaintainDBCmd restore' '-A' '$teamCityDataDir' '-F' '$dbBackupOriginPath' '-T' '$dbConfigOriginPath'"
iex "& '$teamCityMaintainDBCmd' 'restore' '-A' '$teamCityDataDir' '-F' '$dbBackupOriginPath' '-T' '$dbConfigOriginPath'"  | Out-Null
#this might fail#
Remove-Item -Recurse -Force C:\ProgramData\JetBrains\TeamCity\config | Out-Null
Remove-Item -Recurse -Force C:\ProgramData\JetBrains\TeamCity\plugins | Out-Null
Remove-Item -Recurse -Force C:\ProgramData\JetBrains\TeamCity\system | Out-Null

echo "### Restart ###"
iex "& '$teamCityMaintainDBCmd' 'restore' '-A' '$teamCityDataDir' '-F' '$dbBackupOriginPath' '-T' '$dbConfigOriginPath'"  

echo "### Give it 5 seconds ###"
Start-Sleep 5

echo "###Unzip Artifacts ###"
iex "& '$7zipExe' 'x' '$artifactsOriginPath' '-aoa' '-o$deployDir'" | Out-Null

echo "###X-Copy Artifacts ###"
iex "& 'xcopy' '$artifactsSrcDir' '$artifactsDestDir' '/E' '/C' '/H' '/R' '/Y' '/O'"

echo "### The End ###"