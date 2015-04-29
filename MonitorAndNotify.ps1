
# Setup variables ----------------------------------------------------------------------------
$apikey = '111111111111111111111111111111111111111111111111';
$proxyUrl = "http://internetproxy:XXXX"

# Helpers ------------------------------------------------------------------------------------
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
	
#Cmdlet to do a 'GET' HTML with shorthand and proxy setup.
function Get-WebRequest([string] $url, [Switch] $SuppressOutput)
{
	if([string]::IsNullOrEmpty($url))
	{
		return $null;
	}
		
	$request = [System.Net.WebRequest]::Create($url);
	$request.Timeout = 10000; #10 seconds
	
	# Proxy setup
	$proxy = New-Object System.Net.WebProxy($proxyUrl);
	$proxy.useDefaultCredentials = $true;
	$request.Proxy = $proxy;
	
	$response = $request.GetResponse();
	if($SuppressOutput)	{ return; }
	
	$enc = [System.Text.Encoding]::GetEncoding(1252);
	$streamReader = New-Object System.IO.StreamReader ( $response.GetResponseStream(), $enc);
	
	return $streamReader.ReadToEnd();
}

# Notification implementations ---------------------------------------------------------------

function Notify-Balloon([string] $event, [string] $description=".", [string] $application='Powershell')
{
	#From http://blogs.msdn.com/b/buckwoody/archive/2010/03/23/powershell-show-a-notification-balloon.aspx
	
#[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")

	$notification = New-Object System.Windows.Forms.NotifyIcon 
	$notification.Icon = "C:\ccviews\TBL\C_TBL\src\WinUI\Austin.ico"

	# You can use the value Info, Warning, Error 
	$notification.BalloonTipIcon = "Info"

	# Put what you want to say here for the Start of the process 
	$notification.BalloonTipTitle = "$application: $event"
	$notification.BalloonTipText = "$description"
	$notification.Visible = $True
	$notification.ShowBalloonTip(10000)
}

function Notify-Dialog([string] $event, [string] $description=".", [string] $application='Powershell')
{
	#From http://michlstechblog.info/blog/powershell-show-a-messagebox/

	$oReturn=[System.Windows.Forms.Messagebox]::Show($description, "$event - $application");
}

function Notify-Android([string] $event, [string] $description, [string] $application='Powershell')
{
	return Get-WebRequest "https://www.notifymyandroid.com/publicapi/notify?apikey=$apikey&application=$application&event=$event&description=$description" -SuppressOutput;
}

#'GET' Notify my Android URL, pushing message in QueryString.  e.g.:
#	Notify-Android "Title" "Description text";
#	long-running.cmd; Notify-Android "Long running task complete";
#	cmdlet-with-output | Notify-Android;
function Notify()
{
	param(
		[string] $OverrideEvent,
		[string] $OverrideDescription,
		[string] $Application = 'Powershell',
		[Switch] $Android,
		[Switch] $Balloon,
		[Switch] $Email,
		
		[Parameter(ValueFromPipeline = $true)]
		[object[]] $InputObject
	)
	
	begin
	{		
		$event = '';
		$description = '';
		if((h) -ne $null -and (h).length -gt 0)
		{
			$event = (h)[-1].CommandLine;
		}
		
		if(-! $Android -and -! $Balloon -and -! $Email)
		{
			$Balloon = $true;
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
		
		if($Android)
		{
			Notify-Android $event $description $Application;
		}
		
		if($Balloon)
		{
			Notify-Android $event $description $Application;
		}
		
		if($Email)
		{
			Notify-Email $event $description $Application;
		}
	}
}

# Monitoring Functions -----------------------------------------------------------------

#Utility to get API URL from jenkins (for use in 'PollForResult' cmdlet).  Returns URL(s) of the form:
#	http://jenkins:8080/view/Build/job/jobName/45/api/xml
function Get-ApiUrlFromJenkins([string] $search, [string] $type="job", [string] $jenkinsServer="http://jenkins:8080", [Switch] $ForApi)
{
	[string] $xpath = "/*/$type";
		
	foreach ($term in $search.split(' '))
	{
		$xpath = ('{0}[contains(name,"{1}")]' -f $xpath, $term);
	}
	
	$xpath = '{0}/url/text()' -f $xpath;
	[xml] $xcontent = Get-WebRequest $('{0}/api/xml' -f $jenkinsServer);
	$results = [string[]]$(Select-Xml -xpath $xpath -xml $xcontent);
	
	if($ForApi)
	{
		return $results | % { "{0}lastBuild/api/xml" -f $_ };
	}
	
	return $results;
}

# Polls a URL, searching returned XML using XPATH.  When 
#
#example usage:
#	Notify-PollResultEquals "http://jenkins:8080/view/Build/job/jobName/45/api/xml" "/freeStyleBuild/building" "false"
#	Notify-PollResultEquals "http://jenkins:8080/view/Build/job/jobName/lastBuild/api/xml" 
function Notify-PollResultEquals([string] $url, [string] $selector="/freeStyleBuild/building", [string] $value="false", [Int32] $sleepPeriod=30, [Switch] $SuppressOutput) 
{
	[string] $currentValue = '';
	$cycles = 0;
	while($currentValue -ne $value -and $cycles -le 500)
	{				
		$content = Get-WebRequest $url;

		[xml] $xmlContent = $content;
		$currentValue = [string](Select-Xml -XPath "$selector/text()" -Xml $xmlContent);

		$cycles = $cycles + 1;
		if(-! $SuppressOutput)
		{
			$date = $(Date).toString("HH:mm:ss");
			Write-Host "$date - Looking for: $value, found: $currentValue"
		}
		
		if($currentValue -eq $value)
		{
			return;
		}
		sleep -Seconds $sleepPeriod;
	}
	
	Notify "PollForResult complete" "$selector = $currentValue";
}

#Cmdlet to monitor a queue, notifying when message count is zero
function Notify-QueueComplete([string] $queueName = 'concurrent', [int] $delay = 20, [int] $maxIterations = 10000, [Switch] $warnOnNoChange=$false, [Switch] $Verbose=$false)
{
	$nMinusOneCount = 0;
	$nMinusTwoCount = 0;
	
	if($Verbose)
	{
		Write-Host "Notify-QueueComplete initialising..."
	}
	
	for($i=0; $i -lt $maxIterations;$i=$i+1)
	{
		Sleep -Seconds $delay;
		$numMessages = $(gwmi Win32_PerfFormattedData_msmq_MSMQQueue | ? {$_.Name.Contains($queueName)}).MessagesInQueue;
		if($Verbose)
		{
			Write-Host "$numMessages messages found."
		}
			
		if($numMessages -eq 0)
		{
			Notify-Android "MSMQ" "$queueName queue processing complete.";
			return;
		}
		
		if($warnOnNoChange)
		{
			if($numMessages -eq $nMinusOneCount -and $numMessages -eq $nMinusTwoCount)
			{#Last two iterations had same message count
				
				if($Verbose)
				{
					Write-Host "$queueName queue stuck on '$numMessages' messages after 3 retries.  Disabling warnings..."
				}
				Notify-Android "MSMQ" "$queueName queue stuck on '$numMessages' messages after 3 retries.  Disabling";
				$warnOnNoChange = $false;
			}
			
			$nMinusTwoCount = $nMinusOneCount;
			$nMinusOneCount = $numMessages;
		}		
	}
}
