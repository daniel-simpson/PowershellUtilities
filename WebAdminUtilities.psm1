
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

function Set-DefaultAppPool32Bit([boolean]$value)
{
    $app = Get-Item IIS:\AppPools\DefaultAppPool;
    $app.enable32BitAppOnWin64 = $value;
    $app | Set-Item;
}
