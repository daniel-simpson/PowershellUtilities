 
If (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
{
    Write-Warning "You do not have Administrator rights to run this script!`nPlease re-run this script as an Administrator!"
    Break;
}

if(${env:ProgramFiles(x86)} -eq $null)
{
	Write-Warning This script only works on x64 machines and x64 powershell.  Exiting...
	Break;
}

function EscapeSpecialCharacters([string] $str)
{
	return $str;
}

$shells = @{};
$shells["Powershell64"] = "$env:windir\System32\WindowsPowerShell\v1.0\powershell.exe";
$shells["Powershell32"] = "$env:windir\SysWOW64\WindowsPowerShell\v1.0\powershell.exe";
$shells["Cmd64"] = "$env:windir\System32\cmd.exe";
$shells["Cmd32"] = "$env:windir\SysWOW64\cmd.exe";

function RunAllCmdPermutations ([string] $scriptCommand, [string] $args=$null, [Switch] $All, [Switch] $Powershell64, [Switch] $Powershell32, [Switch] $Cmd64, [Switch] $Cmd32)
{
	#Default setup
	if(-not ($All -and $Powershell64 -and $Powershell32 -and $Cmd64 -and $Cmd32)) {	$All = $true; }
	
	if($Powershell64 -or $All)
	{
		. $shells["Powershell64"] -NoExit -WindowStyle Normal -ExecutionPolicy Unrestricted -command "& {& '$scriptCommand' '$args'}" );
	}
	
	if($Powershell32 -or $All)
	{
		. $shells["Powershell32"] -NoExit -WindowStyle Normal -ExecutionPolicy Unrestricted -command "& {& '$scriptCommand' '$args'}" );
	}
	
	if($Cmd64 -or $All)
	{
		. $shells["Cmd64"] /K $scriptCommand $args;
	}
	
	if($Cmd32 -or $All)
	{
		. $shells["Cmd32"] /K $scriptCommand $args;
	}
}
