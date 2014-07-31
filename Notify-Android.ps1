$apikey = 'INSERT API KEY HERE';

function Notify-Android()
{
	param(
		[string] $OverrideEvent,
		[string] $OverrideDescription,
		
		[Parameter(ValueFromPipeline = $true)]
		[object[]] $InputObject
	)
	
	begin
	{
	  # Internet Proxy settings setup
		#$proxy = New-Object System.Net.WebProxy("http://internetproxy:3128");
		#$proxy.useDefaultCredentials = $true;
		
		$event = '';
		$description = '';
		if((h) -ne $null -and (h).length -gt 0)
		{
			$event = (h)[-1].CommandLine;
		}
	}
	
	process
	{
		if($_ -ne $null)
		{
			if(-! [string]::IsNullOrEmpty($_.ToString()))
			{
				$description = $_;
			}
			$_;
		}
	}
	
	end
	{
		if(-! [string]::IsNullOrEmpty($OverrideEvent)) { $event = $OverrideEvent; }
		if(-! [string]::IsNullOrEmpty($OverrideDescription)) { $description = $OverrideDescription; }
		if([string]::IsNullOrEmpty($event)) { $event = 'No event'; }
		if([string]::IsNullOrEmpty($description)) { $description = '.'; }
		
		$request = [System.Net.WebRequest]::Create("https://www.notifymyandroid.com/publicapi/notify?apikey=$apikey&application=Powershell&event=$event&description=$description");
		$request.Proxy = $proxy;
		$request.GetResponse();
	}
}

New-Alias -Name na -Value Notify-Android -errorAction SilentlyContinue;
