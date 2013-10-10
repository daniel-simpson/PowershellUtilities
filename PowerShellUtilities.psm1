
#Powershell utility library

#	Please note, the following variables will need to be set in your own powershell profile at:
#   	"C:\Users\<Username>\Documents\WindowsPowerShell\Microsoft.Powershell_profile.ps1"
#
#	Necessary:
#		$DebugBrowser = "C:\Program Files (x86)\Internet Explorer\iexplore.exe";	#(Web browser to debug projects)
#
#	Optional:
#		$npp = "C:\Program Files (x86)\Notepad++\notepad++.exe"; 					#(Favourite text editor, mine is notepad++)

if(-not $(Import-Module WebAdministration -ErrorAction SilentlyContinue))
{
	Write-Output "WebAdministration module was not loaded successfully, please make sure that this feature is enabled in 'Programs and Features' -> 'Turn Windows features on or off' -> 'Internet Information Services' -> 'Web Management Tools'.";
}

$i = "IIS Admin Service";

function Get-FunctionExists([string] $functionName)
{
	if(Get-Command $functionName -ErrorAction SilentlyContinue)
	{
		return $true;
	}
	return $false;
}

function Set-DefaultAppPool32Bit([boolean]$value)
{
	$app = Get-Item IIS:\AppPools\DefaultAppPool;
	$app.enable32BitAppOnWin64 = $value;
	$app | Set-Item;
}

function StopProcess([string]$processName)
{
    $arg = '"' + $processName + '*"';
    taskkill /f /im $arg;
}
function Get-FSObjectExists([string] $path)
{
	return $(Get-Item $path -errorAction SilentlyContinue) -ne $null;
}
function RemoveLinesFromFile([string] $filename, [int] $startLine, [int] $endLine)
{
	$content = Get-Content $filename;
	$out = @();
	$out += $content[0..($startLine-1)];
	$out += $content[($endLine+1)..($content.Count-1)];
	$out | Out-File $filename;
}
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

}

$Host.UI.RawUI.WindowTitle = "Powershell with Dan's scripts: ";