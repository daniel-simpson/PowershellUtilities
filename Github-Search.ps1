# NOTE: In order to use this script you will need to either:
#   - Set a "githubAuthHeader" environment variable (including "Basic " keyword and base64 encoded "username:PAT")
#   - Pass in an Auth header value (same format)

function Search-GithubRepos($language = "HCL", $organisation = "AGLEnergy", $authHeader = $null)
{
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12;

    if($authHeader -eq $null -or $authHeader.length -eq 0) 
    {
        $authHeader = $env:githubAuthHeader;
    }

    $headers = @{ Authorization = $authHeader };

    $response = Invoke-WebRequest -Headers $headers -uri "https://api.github.com/search/repositories?q=language:$language+org:$organisation";

    $data = $($response.Content) | ConvertFrom-Json;

    return @{
        total_count = $data.total_count;
        incomplete_results = $data.incomplete_results;
        clone_urls = $data.items | % { $_.ssh_url };
    };
}
