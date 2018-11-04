# http://stackoverflow.com/questions/1183183/path-of-currently-executing-powershell-script
$root = Split-Path $MyInvocation.MyCommand.Path -Parent;

Import-Module NuGetUcsb
Import-Module CoreUcsb
    # Uses: Add-PsTypeField
    # Used By: SecretServerUcsb

# bump up TLS to 1.2
[System.Net.ServicePointManager]::SecurityProtocol = 
				[System.Net.SecurityProtocolType]::Tls12 + [System.Net.SecurityProtocolType]::Tls11 + [System.Net.SecurityProtocolType]::Tls;

if($global:MyGetUcsb -eq $null) {
    $global:MyGetUcsb = @{};

	# get username / password for management API
	import-module secretserverucsb

	$secret = get-secretserversecret -filter "myget.org - sist-ucsb" |? { $_.Id -eq 3386 }
	$username = $secret.Username
	$password = $secret.Password
	$basicCred = "$($username):$($password)"
	$basicCredEncoded = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($basicCred))
	$basicAuth = "Basic $basicCredEncoded"
	$global:MyGetUcsb.BasicAuthHeader = @{
											Authorization = $basicAuth;
										};


	$secret = get-secretserversecret -filter "myget.org - sist-ucsb - apikey"
	$global:MyGetUcsb.ApiKey = $secret.password

	$bearerAuth = "Bearer $($global:MyGetUcsb.ApiKey)"
	$global:MyGetUcsb.AuthHeader = @{
                                        Authorization = $bearerAuth;
                                        Accept = "application/json;charset=utf-8"
                                    };

	$global:MyGetUcsb.ApiUrl = "https://sist-ucsb.myget.org/_api/v1"
    $global:MyGetUcsb.FeedUrlFormat = "https://sist-ucsb.myget.org/F/{0}/api/v2/package"
}

$ExecutionContext.SessionState.Module.OnRemove += {
    Remove-Variable -Name MyGetUcsb -Scope global
}

# grab functions from files (from C:\Chocolatey\chocolateyinstall\helpers\chocolateyInstaller.psm1)
Resolve-Path $root\MyGetUcsb.*.ps1 | 
	? { -not ($_.ProviderPath.Contains(".Tests.")) } |
	% { . $_.ProviderPath; }


