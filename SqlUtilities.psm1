
function ExecuteSQL([string] $command, [string] $connectionString)
{
	$SqlConnection = New-Object System.Data.SqlClient.SqlConnection
	$SqlConnection.ConnectionString = $connectionString

	$SqlCmd = New-Object System.Data.SqlClient.SqlCommand
	$SqlCmd.CommandText = $command
	$SqlCmd.Connection = $SqlConnection

	$SqlAdapter = New-Object System.Data.SqlClient.SqlDataAdapter
	$SqlAdapter.SelectCommand = $SqlCmd

	$DataSet = New-Object System.Data.DataSet
	$SqlAdapter.Fill($DataSet)
	 
	$SqlConnection.Close()

	return $DataSet.Tables[0];
}

function ExecuteSQL([string] $command, [string] $Server, [string] $DBName, [string] $SQLuser, [string] $SQLpass)
{
	$connectionString = "Data Source="+$server+";Initial Catalog="+$DBName+";uid="+$SQLuser+";pass="+$SQLpass+";";
	ExecuteSql($command, $connectionString);
}
