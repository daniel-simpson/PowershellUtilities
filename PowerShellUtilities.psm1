
function Get-FunctionExists([string] $functionName)
{
	if(Get-Command $functionName -ErrorAction SilentlyContinue)
	{
		return $true;
	}
	return $false;
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
$Host.UI.RawUI.WindowTitle = "Powershell with Dan's scripts: ";
