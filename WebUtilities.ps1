[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
$proxyUrl = "http://internetproxy:PORT"
function Get-WebRequest([string] $url, [Switch] $SuppressOutput)
{
	if([string]::IsNullOrEmpty($url))
	{
		return $null;
	}
		
	$request = [System.Net.WebRequest]::Create($url);
	$request.Timeout = 10000; #10 seconds
	
	# Internet Proxy settings setup
	$proxy = New-Object System.Net.WebProxy($proxyUrl);
	$proxy.useDefaultCredentials = $true;
	$request.Proxy = $proxy;
	
	$response = $request.GetResponse();
	if($SuppressOutput)
	{
		return;
	}
	
	$enc = [System.Text.Encoding]::GetEncoding(1252);
	$streamReader = New-Object System.IO.StreamReader ( $response.GetResponseStream(), $enc);
	
	return $streamReader.ReadToEnd();
}


function Post-WebRequest([string] $url, [string] $postData, $Credential = $(Get-Credential))
{
	if([string]::IsNullOrEmpty($url))
	{
		return $null;
	}
	
    $webRequest = [System.Net.WebRequest]::Create($url)
    $webRequest.ContentType = "application/json"
    $PostStr = [System.Text.Encoding]::UTF8.GetBytes($postData)
    $webrequest.ContentLength = $PostStr.Length
    $webRequest.ServicePoint.Expect100Continue = $false
    $webRequest.Credentials = $Credential

    $webRequest.PreAuthenticate = $true
    $webRequest.Method = "POST";

	$proxy = New-Object System.Net.WebProxy($proxyUrl);
	$proxy.useDefaultCredentials = $true;
	$webRequest.Proxy = $proxy;

    $requestStream = $webRequest.GetRequestStream()
    $requestStream.Write($PostStr, 0,$PostStr.length)
    $requestStream.Close()

    [System.Net.WebResponse] $resp = $webRequest.GetResponse();
    $rs = $resp.GetResponseStream();
    [System.IO.StreamReader] $sr = New-Object System.IO.StreamReader -argumentList $rs;
    [string] $results = $sr.ReadToEnd();

    return $results;
}

function Get-UrlFromJenkins([string] $search, [string] $type="job", [string] $jenkinsServer="http://<jenkins>:8080", [Switch] $ForApi)
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
