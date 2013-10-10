
#Filters
function Is-Excel
{
	BEGIN 		{ $regex = [Regex] '.*\.xls[x]{0,1}$'; }
	PROCESS		{ if ($regex.Match($_).Success) { return $_; } }
	END			{ $regex = $null; }
}

function Is-Csv
{
	BEGIN 		{	$regex = [Regex] '.*\.csv$'; }
	PROCESS		{ if ($regex.Match($_).Success) { return $_; } }
	END			{ $regex = $null; }
}

function ConvertExcel-ToCsv([string] $inFile, [string] $outFile='')
{
	if(-! (Test-Path $inFile))
	{
		Write-Host "Enter a valid path for input file: $inFile";
		return;
	}
	
	$in = Get-ChildItem $inFile;
	
	if($outFile.Length -lt 1)
	{
		$outFile = $in.FullName + ".csv"
	}
	
	$excel = New-Object -comObject excel.application;
	$excel.Visible = $true;
	$excel.displayalerts=$False
	
	$wb = $excel.workbooks.open($in.FullName);
	$wb.SaveAs($outFile,6);
	$excel.workbooks.close();
	
	$excel.Quit();
	return $outFile;
}

function ConvertExcel-ToCsvFromDirectory([string] $dirName)
{
	if(-! (Get-Item $dirName).PSIsContainer)
	{
		Write-Host 'Please input a directory name';
		return;
	}
	
	Get-ChildItem $dirName | Is-Excel | foreach { ConvertExcel-ToCsv $_ };
}

function ConvertCsv-ToJson([string] $inFile, [string] $outFile='')
{
	if(-! (Test-Path $inFile))
	{
		Write-Host "Enter a valid path for input file: $inFile";
		return;
	}
	
	$in = Get-ChildItem $inFile;
	
	if($outFile.Length -lt 1)
	{
		$outFile = $in.FullName + ".json"
	}
	
	Import-Csv $in.FullName | ConvertTo-Json | Out-File $outFile;
	return $outFile;
}