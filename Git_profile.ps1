
# ENVIRONMENT SETUP
function SetEnvironmentVariable-IfNotExist([string] $variableName, $newValue)
{
	if($(Get-Variable $variableName -errorAction SilentlyContinue) -eq $null)
	{
		#Variable is not set, so set new value
		Set-Variable $variableName $newValue;
	}
}

SetEnvironmentVariable-IfNotExist pcUserName "daniel.simpson"
SetEnvironmentVariable-IfNotExist userHome  "C:\users\$pcUserName"
SetEnvironmentVariable-IfNotExist projectHome "C:\Projects"

# GIT SETUP
Import-Module posh-git

$GitPromptSettings.BeforeText = " [ branch: "
$GitPromptSettings.AfterText = " ] "
$GitPromptSettings.BranchBackgroundColor = [ConsoleColor]::Gray
$GitPromptSettings.BranchForegroundColor = [ConsoleColor]::Red
$GitPromptSettings.BeforeForegroundColor = [ConsoleColor]::Black
$GitPromptSettings.BeforeBackgroundColor = [ConsoleColor]::Gray
$GitPromptSettings.AfterBackgroundColor = [ConsoleColor]::Gray
$GitPromptSettings.AfterForegroundColor = [ConsoleColor]::Black
$GitPromptSettings.BranchAheadBackgroundColor = [ConsoleColor]::White
$GitPromptSettings.BranchAheadForegroundColor = [ConsoleColor]::Black

$GitPromptSettings.RepositoriesInWhichToDisableFileStatus = {"$projectHome\ProjectName"}

Write-Host "Starting SSH agent..."
Start-SshAgent -Quiet
