# This file shouldn't be run on it's own. It should be loaded using the MyGetUcsb Module.

<#
.SYNOPSIS
    Retrieve feed privileges

.DESCRIPTION
	Required API scopes: `feed:read` - The authenticated user must be owner or co-owner of the feed.

	Example request:

		GET https://www.myget.org/_api/v1/feed/<feed name>/privileges?includeInvites=<true|false>
		Authorization: Bearer <your API key>
		Accept: application/json

	Parameters:
		* `includeInvites` - Boolean, whether to include users who have a pending invitation to the feed.

	Example response:

		{
			"id": "feedname",
			"privileges": [
				{
					"username": "testuserapi",
					"email": null, // note: email is only shown for pending invitations
					"privilege": "Owner"
				},
				{
					"username": "maartenba2",
					"email": null, // note: email is only shown for pending invitations
					"privilege": "Consumer"
				}
			],
			"invites": [
				{
					"username": "", // note: username can not be shown for pending invitations
					"email": "user@example.org",
					"privilege": "Consumer"
				}
			]
		}
	
	The returned `privilege` can be:

	* `NoAccess` - "Has no access to this feed"
	* `Owner` - "Owner of this feed" (all privileges)
	* `CoOwner` - "Can manage users and all packages for this feed"
	* `FeedContributor`  - "Can manage all packages for this feed"
	* `PackageContributor` - "Can contribute own packages to this feed"
	* `Consumer` - "Can consume this feed"
	* `ConsumerAfterLogin` - "Can consume this feed only with a valid MyGet login"

	Possible response codes:

	* *200 OK* - Feed privileges are returned.
	* *404 Not found* - Feed does not exist.
	* *401 Unauthorized* - API call is not authenticated.
	* *403 Forbidden* - This operation can not be performed by the current user.

	For all responses, the response body may contain validation errors in JSON format, for example:

		{
			"errors": {
				"privilege": ["Invalid feed privilege."]
			}
		}

.PARAMETER Feed
	The name of the feed

.PARAMETER IncludeInvites
    Boolean, whether to include users who have a pending invitation to the feed.

.EXAMPLE
	$public = Get-MyGetFeedPrivilege -Feed public
#>
Function Get-MyGetFeedPrivilege {
[CmdletBinding()]
[OutputType([PSCustomObject])]
Param (
	[Parameter(Mandatory = $true, ValueFromPipeline = $true)]
    [ValidateSet("public","internal","internal-nonprod")]
	[string] $Feed,
	[Parameter(Mandatory = $false, ValueFromPipeline = $true)]
	[switch] $IncludeInvites
)
begin {
	$results = @()
}
process {
	
	$url = "/feed/$Feed/privileges"
	if($IncludeInvites) { $url += "?includeInvites=" + $IncludeInvites }

	$response = Invoke-MyGetRequest -ApiPath $url
	$result = ConvertFrom-Json $response.Content
	
	$results += @($result)
}
end {
	return $results
}
}




<#
.SYNOPSIS
    Sets a user to a feed with specific privileges. To remove priveleges use "NoAccess".

.DESCRIPTION
	Required API scopes: `feed:write` - The authenticated user must be owner or co-owner of the feed.

	Example request:

		POST https://www.myget.org/_api/v1/feed/<feed name>/privileges
		Authorization: Bearer <your API key>
		Content-type: application/json
		Accept: application/json
    
		{
			"username": "testuserapi",
			"email": "",
			"privilege": "FeedContributor"
		}

	The `privilege` can be:

	* `NoAccess` - "Has no access to this feed"
	* `Owner` - "Owner of this feed" (all privileges)
	* `CoOwner` - "Can manage users and all packages for this feed"
	* `FeedContributor`  - "Can manage all packages for this feed"
	* `PackageContributor` - "Can contribute own packages to this feed"
	* `Consumer` - "Can consume this feed"
	* `ConsumerAfterLogin` - "Can consume this feed only with a valid MyGet login"

	Possible response codes:

	* *202 Accepted* - Change of privileges will be processed by the MyGet back-end.
	* *404 Not found* - Feed does not exist.
	* *400 Bad Request* - Validation failed.
	* *409 Conflict* - User already has access to the feed.
	* *401 Unauthorized* - API call is not authenticated.
	* *403 Forbidden* - This operation can not be performed by the current user.
	* *402 Payment Required* - Privileges can not be applied. The number of contributors exceeds the maximum number of allowed contributors for the feed owner's subscription.

	For all responses, the response body may contain validation errors in JSON format, for example:

		{
			"errors": {
				"privilege": ["Invalid feed privilege."]
			}
		}

.PARAMETER Feed
	The name of the feed

.PARAMETER Username
	A specific user to add

.PARAMETER Privilege
    * `NoAccess` - "Has no access to this feed"
	* `Owner` - "Owner of this feed" (all privileges)
	* `CoOwner` - "Can manage users and all packages for this feed"
	* `FeedContributor`  - "Can manage all packages for this feed"
	* `PackageContributor` - "Can contribute own packages to this feed"
	* `Consumer` - "Can consume this feed"
	* `ConsumerAfterLogin` - "Can consume this feed only with a valid MyGet login"

.EXAMPLE
	$public = Set-MyGetFeedUserPrivilege -Feed public -Username maglio-s -Privilege FeedContributor
#>
Function Set-MyGetFeedUserPrivilege {
[CmdletBinding()]
[OutputType([PSCustomObject])]
Param (
	[Parameter(Mandatory = $true, ValueFromPipeline = $true)]
	[string] $Feed,
	[Parameter(Mandatory = $true, ValueFromPipeline = $true)]
	[string] $Username,
	[Parameter(Mandatory = $true, ValueFromPipeline = $true)]
	[ValidateSet("NoAccess","Owner","CoOwner","FeedContributor","PackageContributor","Consumer","ConsumerAfterLogin")]
	[string] $Privilege = "NoAccess"
)
begin {
	$results = @()
}
process {

	if((Test-MyGetUserExists -Username $Username) -eq $false) {
		$message = "New-MyGetFeedUserPrivilege: User '$Username' does not exist."
		throw $message
	}
	
	$url = "/feed/$Feed/privileges"
	$privilegeParams = @{
		Username = $Username
		Email = ""
		Privilege = $Privilege
	};

	$response = Invoke-MyGetRequest -ApiPath $url -Method Post -Body $privilegeParams
	$result = ConvertFrom-Json $response.Content
	
	$results += @($result)
}
end {
	return $results
}
}





[string[]]$funcs =
	"Get-MyGetFeedPrivilege", "Set-MyGetFeedUserPrivilege"

Export-ModuleMember -Function $funcs