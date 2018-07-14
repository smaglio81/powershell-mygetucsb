# This file shouldn't be run on it's own. It should be loaded using the MyGetUcsb Module.


<#
.SYNOPSIS
	Makes a call to the MyGet Management API. It adds the authorization header and
	uses the root url for our organizations management api endpoint ($global:MyGetUcsb.ApiUrl).
	This returns the body of the response as a string.

.PARAMETER ApiPath
	The sub path that will be added onto $global:MyGetUcsb.ApiUrl.

.EXAMPLE
	$developers = Invoke-MyGetMethod -ApiPath "/developers"
#>
Function Invoke-MyGetRest {
[CmdletBinding()]
Param (
	[Parameter(Mandatory = $true)]
	[string] $ApiPath,
	[ValidateSet("Default","Delete","Get","Head","Merge","Options","Patch","Post","Put","Trace")]
	[string] $Method = "Default",
	[object] $Body = $null,
	[string] $ContentType = "application/json",
    [string] $OutFile = $null
)

	if($ApiPath.StartsWith("/") -eq $false) {
		$ApiPath = "/$ApiPath"
	}
	$Uri = $global:MyGetUcsb.ApiUrl + $ApiPath

	if($Body -eq $null) {
		$result = Invoke-RestMethod `
                    -Uri $Uri `
                    -Method $Method `
                    -Headers $global:MyGetUcsb.AuthHeader `
                    -ContentType $ContentType `
                    -OutFile $OutFile
	} else {
		$result = Invoke-RestMethod `
                    -Uri $Uri `
                    -Method $Method `
                    -Headers $global:MyGetUcsb.AuthHeader `
                    -Body $Body `
                    -ContentType $ContentType `
                    -OutFile $OutFile
	}
	
	return $result
}

<#
.SYNOPSIS
	Makes a call to the MyGet Management API. It adds the authorization header and
	uses the root url for our organizations management api endpoint ($global:MyGetUcsb.ApiUrl).
	This returns the Response object.

	If the status code is 1XX/2XX/3XX ("success" status codes), then the return object is
	[Microsoft.PowerShell.Commands.WebResponseObject].

	If the status code is 4xx/5xx ("error" status codes), then the return object is
	[System.Net.HttpWebResponse].

.PARAMETER ApiPath
	The sub path that will be added onto $global:MyGetUcsb.ApiUrl.

.EXAMPLE
	$response = Invoke-MyGetMethod -ApiPath "/developers"
#>
Function Invoke-MyGetRequest {
[CmdletBinding()]
[OutputType([System.Net.HttpWebResponse])]
Param (
	[Parameter(Mandatory = $true)]
	[string] $ApiPath,
	[ValidateSet("Default","Delete","Get","Head","Merge","Options","Patch","Post","Put","Trace")]
	[string] $Method = "Default",
	[object] $Body = $null,
	[string] $ContentType = "application/json"
)

	if($ApiPath.StartsWith("/") -eq $false) {
		$ApiPath = "/$ApiPath"
	}
	$Uri = $global:MyGetUcsb.ApiUrl + $ApiPath

	try {
		if($Body -eq $null) {
			$result = Invoke-WebRequest -Uri $Uri -Method $Method -Headers $global:MyGetUcsb.AuthHeader -ContentType $ContentType
		} else {
            $json = ConvertTo-Json -InputObject $Body -Depth 100
			$result = Invoke-WebRequest -Uri $Uri -Method $Method -Headers $global:MyGetUcsb.AuthHeader -Body $json -ContentType $ContentType
		}
	} catch {
		$result = $_.Exception.Response

        $content = Get-MyGetErrorResponseBody -Response $result
        Add-PsTypeField -PSObject $result -Name Content -Value $content
	}
	
	return $result
}

<#
.SYNOPSIS
	This can extract the reponse body from the result of Invoke-MyGetRequest.
	This should only be used if the response from the server has a status code
	of 4XX/5XX (the error status codes).

.PARAMETER Response
	The result of Invoke-MyGetRequest (not Invoke-MyGetRest). Has to be of
	type [System.Net.HttpWebResponse].

.EXAMPLE
	$response = Invoke-MyGetRequest -ApiPath "/developers"
	if($response.StatusCode -ne "
#>
Function Get-MyGetErrorResponseBody {
[CmdletBinding()]
Param (
	[System.Net.HttpWebResponse] $Response
)
	$stream = $Response.GetResponseStream()
	$null = $stream.Seek(0, [IO.SeekOrigin]::Begin)
	if($stream.Length -eq 0) { return ""; }

	$reader = New-Object IO.StreamReader $stream, [Text.Encoding]::UTF8
	$body = $reader.ReadToEnd()
	$null = $stream.Seek(0, [IO.SeekOrigin]::Begin)
	$reader.Dispose()

    return $body
}



[string[]]$funcs =
	"Invoke-MyGetRest", "Invoke-MyGetRequest", "Get-MyGetErrorResponseBody"

Export-ModuleMember -Function $funcs