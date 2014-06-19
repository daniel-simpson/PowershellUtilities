
$geocode = 'https://maps.googleapis.com/maps/api/geocode/json?sensor=false&address=';
function Lookup-GooglePlaces([string] $address)
{ 
	if($address.Length -lt 1)
	{
		Write-Host 'Please enter a valid address for lookup.';
		return $null;
	}

	$ret = Invoke-WebRequest $($geocode + $address);
	
	if($ret.StatusCode -ne 200)
	{
		Write-Host 'Error in web request: ' $ret;
		return $null;
	}
	
	$json = $ret.Content | ConvertFrom-Json;
	
	$c = $json.results.Count;
	if($c -ne 1)
	{
		Write-Host "Wrong number of results ($c) for address '$address'";
		return $null;
	}
	
	$returnValue = New-Object System.Object;
	Add-Member -InputObject $returnValue -MemberType NoteProperty -Name InputAddress -Value $address;
	Add-Member -InputObject $returnValue -MemberType NoteProperty -Name FormattedAddress -Value $json.results[0].formatted_address;
	Add-Member -InputObject $returnValue -MemberType NoteProperty -Name Latitude -Value $json.results[0].geometry.location.lat;
	Add-Member -InputObject $returnValue -MemberType NoteProperty -Name Longitude -Value $json.results[0].geometry.location.lng;
	
	return $returnValue;
}

function Lookup-GooglePlacesFromCsv([string] $inFile, [string] $outFile, [string] $column='Address')
{
	if(-! (Test-Path $inFile))
	{
		Write-Host "Invalid input file $inFile";
		return;
	}

	$places = Import-Csv $inFile;
	foreach($place in $places)
	{
		$t= $(Lookup-GooglePlaces $place.$column);
		if($t -ne $null)
		{
			$place.Lat = $t.Latitude;
			$place.Lng = $t.Longitude;
		}
	};
	$places | Export-Csv $outFile;
}
