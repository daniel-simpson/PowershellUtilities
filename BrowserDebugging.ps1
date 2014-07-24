
$DebugBrowser = "C:\Program Files (x86)\Internet Explorer\iexplore.exe";

$browsers = @{}
$browsers["chrome"] = "C:\Users\daniel.simpson\AppData\Local\Google\Chrome\Application\chrome.exe"
$browsers["iexplore"] = 'C:\Program Files\Internet Explorer\iexplore.exe'
$browsers["firefox"] = "C:\PortableApps\FirefoxPortable\FirefoxPortable.exe"
$browsers["Opera"] = "C:\Program Files (x86)\Opera\launcher.exe"
$browsers["Safari"] = "C:\Program Files (x86)\Safari\Safari.exe"

function Display-Website([string] $url, [Switch] $All, [Switch] $Common, [Switch] $Chrome, [Switch] $IE, [Switch] $Firefox, [Switch] $Opera, [Switch] $Safari, [Switch] $Responsive)
{
	#Default setup
	if(-not ($All -and $Common -and $Chrome -and $IE -and $Firefox -and $Opera -and $Safari))
	{
		$Common = $true;
	}
	
	if($Responsive)
	{
		$url = "http://springload.responsinator.com/?url="+$url;
	}
	
	if($Chrome -or $All -or $Common)
	{
		. $browsers["chrome"] "-incognito" $url;
	}
	
	if($IE -or $All -or $Common)
	{
		. $browsers["iexplore"] "-private" $url;
	}
	
	if($Firefox -or $All)
	{
		. $browsers["firefox"] $url;
	}
	
	if($Opera -or $All)
	{
		. $browsers["Opera"] "-newprivatetab" $url;
	}
	
	if($Safari -or $All)
	{
		. $browsers["Safari"] $url;
	}
}
