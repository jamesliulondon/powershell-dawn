$SQLServer = "sqlserver" #use Server\Instance for named SQL instances! 
$SQLDBName = "master"
$SqlQuery = "create database LONINSIGHTTOOLSTEAMCITY"
$ConnectionString = "Server = $SQLServer; Database = $SQLDBName; Integrated Security = False;UID=sa;PASSWORD=P@ssword1"


$SqlConnection = New-Object System.Data.SqlClient.SqlConnection
$SqlConnection.ConnectionString = $ConnectionString
$SqlCmds = New-Object System.Data.SqlClient.SqlCommand

foreach ($sqlquery in $sqlqueries) {
    Write-Host $sqlquery
    $SqlCmd.CommandText = $SqlQuery
    $SqlCmd.Connection = $SqlConnection
    $SqlAdapter = New-Object System.Data.SqlClient.SqlDataAdapter
    $SqlAdapter.SelectCommand = $SqlCmd
}
 
$SqlConnection.Close()
 
