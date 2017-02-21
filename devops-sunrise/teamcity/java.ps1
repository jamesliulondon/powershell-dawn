$tempdir = "D:\Deploy"
$source = "https://s3-eu-west-1.amazonaws.com/insight-devops/Binaries/jdk-8u121-windows-x64.exe"

$install_origin_path = $tempdir + "\jdk-8u121-windows-x64.exe"

mkdir $tempdir -force | Out-Null
$client = new-object System.Net.WebClient
$client.Headers.Add("Cookie","oraclelicense=accept-securebackup-cookie");
$client.DownloadFile($source, $install_origin_path)

$install_command = @'
& $install_origin_path /s ADDLOCAL="ToolsFeature,PublicjreFeature"
'@

iex $install_command