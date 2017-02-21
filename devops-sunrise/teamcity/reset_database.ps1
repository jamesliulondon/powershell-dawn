$command=@'
& osql -S localhost\SQLEXPRESS -U sa -P P@ssword1
& use master;
& go
& drop database LON-INSIGHT-TOOLS-TEAMCITY
& go
& create database LON-INSIGHT-TOOLS-TEAMCITY
& go
'@

iex '& $command'