

$tempdir = "C:\tmp"
$source = "https://s3-eu-west-1.amazonaws.com/insight-devops/Binaries/jdk-8u121-windows-x64.exe"
$destination = "C:\tmp\jdk-8u121-windows-x64.exe"

mkdir $tempdir -force | Out-Null
$client = new-object System.Net.WebClient
$client.Headers.Add("Cookie","oraclelicense=accept-securebackup-cookie");
$client.DownloadFile($source, $destination)

Invoke-Expression 'C:\tmp\jdk-8u121-windows-x64.exe /s ADDLOCAL="ToolsFeature,PublicjreFeature"'
