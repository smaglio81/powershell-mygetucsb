# This file shouldn't be run on it's own. It should be loaded using the MyGetUcsb Module.

<#
.SYNOPSIS
    Gets user information

.DESCRIPTION
	Required API scopes: `user:read` 

    Example request:

        GET https://www.myget.org/_api/v1/user/<username>
        Authorization: Bearer <your API key>
        Accept: application/json
    
    Example response:
    
        {
            "name": "Maarten Balliauw",
            "username": "testuserapi",
            "website": "http://www.example.com"
        }

    Parameters:
    * `username` - The name of the user to get. When the username `me` is passed in, will get details for the authenticated user instead.

    Possible response codes:

    * *200 OK* - User data is returned.
    * *404 Not found* - User does not exist.
    * *401 Unauthorized* - API call is not authenticated.
    * *403 Forbidden* - This operation can not be performed by the current user.

.PARAMETER Username
    The name of the user to get. When the username `me` is passed in, will get details for the authenticated user instead.

.EXAMPLE
	$user = Get-MyGetUser -Username "maglio-s"
#>
Function Get-MyGetUser {
[CmdletBinding()]
[OutputType([Array])]
Param (
	[Parameter(Mandatory = $true, ValueFromPipeline = $true)]
	[string] $Username
)
begin {
	$results = @()
}
process {
	$response = Invoke-MyGetRequest -ApiPath "/user/$Username"

	switch([int]$response.StatusCode) {
		200 {
			$result = ConvertFrom-Json $response.Content
			$results += @($result)
		}
		404 {
			return
		}
		default {
			$message = ("Get-MyGetUser: Remote server returned an error: ({0}) {1}" -f ([int]$response.StatusCode), $response.StatusDescription)
			if([string]::IsNullOrWhiteSpace($response.Content) -eq $false) {
				$message += [Environment]::NewLine + $response.Content
			}
			throw $message
		}
	}
}
end {
	return $results
}
}

<#
.SYNOPSIS
    Test is a user exists. Uses Get-MyGetUser to test if a user exists.

.PARAMETER Username
    The name of the user to get. When the username `me` is passed in, will get details for the authenticated user instead.

.EXAMPLE
	if(Test-MyGetUserExists -Username "maglio-s" {
		...
	}
#>
Function Test-MyGetUserExists {
[CmdletBinding()]
[OutputType([bool])]
Param (
	[Parameter(Mandatory = $true, ValueFromPipeline = $true)]
	[string] $Username
)

	$user = Get-MyGetUser -Username $Username

	if($user -eq $null) { return $false }

	return $true
}



<#
.SYNOPSIS
    Gets a users public feed information.

.DESCRIPTION
	Required API scopes: `user:read`

    Example request:

        GET https://www.myget.org/_api/v1/user/<username>/feeds
        Authorization: Bearer <your API key>
        Accept: application/json

    Example response:
    
        {
            "name": "Maarten Balliauw",
            "username": "maartenba",
            "feeds": [
                {
                    "id": "testfeed1",
                    "description": "My packages for testing.",
                    "feedType": "public",
                    "ownerUsername": "maartenba"
                },
                {
                    "id": "testfeed2",
                    "description": "My packages for testing - copy.",
                    "feedType": "community",
                    "ownerUsername": "maartenba",
                }
            ]
        }

    Parameters:
    * `username` - The name of the user to get. When the username `me` is passed in, will get details for the authenticated user instead.

    Note the response will only contain `public` and `community` feeds. Only when retrieving details for the authenticated user, `private` and `enterprise` feeds will be included.

    The `feedType` can be:

    * `public`
    * `private`
    * `community`
    * `enterprise` (only for Enterprise plans)

    Possible response codes:

    * *200 OK* - Feed data is returned.
    * *404 Not found* - User does not exist.
    * *401 Unauthorized* - API call is not authenticated.
    * *403 Forbidden* - This operation can not be performed by the current user.

.PARAMETER Username
    The name of the user to get. When the username `me` is passed in, will get details for the authenticated user instead.

.EXAMPLE
	$feeds = Get-MyGetUserFeeds -Username "maglio-s"
#>
Function Get-MyGetUserFeeds {
[CmdletBinding()]
[OutputType([Array])]
Param (
	[Parameter(Mandatory = $true, ValueFromPipeline = $true)]
	[string] $Username
)
begin {
	$results = @()
}
process {
    $response = Invoke-MyGetRequest -ApiPath "/user/$Username/feeds"
    
    switch([int]$response.StatusCode) {
        200 {
            $result = ConvertFrom-Json $response.Content
            $results += @($result)
        }
        default {
            $message = ("Get-MyGetUserFeeds: The remote server returned an error: ({0}) {1}" -f ([int]$response.StatusCode, $response.StatusDescription))
            if([string]::IsNullOrWhiteSpace($response.Content) -eq $false) { $message += "`r`n" + $response.Content }
            throw $message
        }
    }
}
end {
	return $results
}
}



<#
.SYNOPSIS
    Create a new user in the enterprise account.

.DESCRIPTION
	Required API scopes: `user:write` - **Note that this operation must be enabled specifically for your user account by MyGet.**

    Example request:

        POST https://www.myget.org/_api/v1/user
        Authorization: Bearer <your API key>
        Content-type: application/json
        Accept: application/json
    
        {
            "name": "Maarten Balliauw",
            "email": "foo@bar.com",
            "username": "testuserapi",
            "password": "supersecret",
            "website": "http://www.example.com"
            "sendWelcomeEmail": true,
            "sendPasswordResetEmail": true
        }

    Possible response codes:

    * *201 Created* - User was created. When created, the response will include a `Location` header pointing to the newly created resource.
    * *400 Bad Request* - Validation failed.
    * *409 Conflict* - User already exists.
    * *401 Unauthorized* - API call is not authenticated.
    * *403 Forbidden* - This operation can not be performed by the current user.

    For all responses, the response body may contain validation errors in JSON format, for example:

        {
            "errors": {
                "email": ["User with that e-mail address already exists."],
                "username": ["User with that username already exists."]
            }
        }

.PARAMETER Username
    The username (must be unique)

.PARAMETER Name
    The user Full Name

.PARAMETER Email
    The users email (must be unique). If you are using an Identity Provider (SSO), the email address should match the Identity Providers information.

.PARAMETER Password
    (Optional) Default value of 'supersecret'. The users initial password. SendPasswordResetEmail should always be used and the user
    should reset their password on first login. Creating a service account should be done through the web interface, so
    this _should_ not be used.

.PARAMETER Website
    (Optional) Useful when users outside your organization are being added.

.PARAMETER DontSendWelcomeEmail
    (Switch) Should a welcome email not be sent?

.PARAMETER DontSendPasswordResetEmail
    (Switch) Should a password reset email not be sent?
    If a password reset email is sent, then the user will be required to change their password on next login.

.EXAMPLE
	$user = New-MyGetUser -Username "testapi_user" -Name "Test API" -Email "testapi-user@sa.ucsb.edu"
#>
Function New-MyGetUser {
[CmdletBinding()]
[OutputType([Array])]
Param (
    [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
	[string] $Username,
	[Parameter(Mandatory = $true, ValueFromPipeline = $true)]
	[string] $Name,
    [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
	[string] $Email,
    [Parameter(Mandatory = $false, ValueFromPipeline = $true)]
	[string] $Password = "supersecret",
    [Parameter(Mandatory = $false, ValueFromPipeline = $true)]
	[string] $Website = $null,
    [Parameter(Mandatory = $false, ValueFromPipeline = $true)]
	[switch] $DontSendWelcomeEmail,
    [Parameter(Mandatory = $false, ValueFromPipeline = $true)]
	[switch] $DontSendPasswordResetEmail
)
begin {
	$results = @()
}
process {

    $props = @{
        name = $Name
        email = $Email
        username = $Username
        password = $Password
        website = $Website
        sendWelcomeEmail = $true
        sendPasswordResetEmail = $true
    };

    $userParams = New-Object PSCustomObject -Property $props

    if($DontSendWelcomeEmail) { $userParams.sendWelcomeEmail = $false }
    if($DontSendPasswordResetEmail) { $userParams.sendPasswordResetEmail = $false }

	$response = Invoke-MyGetRequest -ApiPath "/user" -Method Post -Body $userParams

    if($response.StatusDescription -ne "Created") {
        $message = "$($response.Content)`r`n`r`nHTTP Status Code: $($response.StatusCode)"
        throw $message
    }

    $result = Get-MyGetUser -Username $Username

	$results += @($result)
}
end {
	return $results
}
}


<#
.SYNOPSIS
    Delete a user in the enterprise account.

.DESCRIPTION
	
    Required API scopes: `user:write` - **Note that this operation must be enabled specifically for your user account by MyGet.**

    Example request:

        DELETE https://www.myget.org/_api/v1/user/<username>?mergeIntoUser=<mergeIntoUser?>
        Authorization: Bearer <your API key>
        Accept: application/json

    Parameters:
    * `username` - The username to delete.
    * `mergeIntoUser` - (optional) The username to transfer `username`'s feeds into.

    Possible response codes:

    * *201 Accepted* - User will be deleted.
    * *404 Not found* - User does not exist.
    * *400 Bad Request* - Validation failed.
    * *401 Unauthorized* - API call is not authenticated.
    * *403 Forbidden* - This operation can not be performed by the current user.

    For all responses, the response body may contain validation errors in JSON format, for example:

        {
            "errors": {
                "mergeIntoUser": ["A user profile cannot be merged into itself."]
            }
        }

.PARAMETER Username
    The username to delete

.PARAMETER MergeIntoUser
    (Optional) The username to transfer `username`'s feeds into.

.EXAMPLE
	$user = Remove-MyGetUser -Username "testapi_user"
#>
Function Remove-MyGetUser {
[CmdletBinding()]
[OutputType([Array])]
Param (
    [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
	[string] $Username,
    [Parameter(Mandatory = $false, ValueFromPipeline = $true)]
	[string] $MergeIntoUser = $null
)
begin {
	$results = @()
}
process {

    $user = Get-MyGetUser -Username $Username
    if($user -eq $null) {
        return;     # user doesn't exist
    }
    
    $apiPath = "/user/$Username"

    if([string]::IsNullOrWhiteSpace($MergeIntoUser) -eq $false) {
        $apiPath += "?mergeIntoUser=$MergeIntoUser"
    }

	$response = Invoke-MyGetRequest -ApiPath $apiPath -Method Delete

    switch([int]$response.StatusCode) {
        201 {
            $results += @($user)
            return
        }
        default {
            $message = ("Remove-MyGetUser: The remote server returned an error: ({0}) {1}" -f ([int]$response.StatusCode, $response.StatusDescription))
            if([string]::IsNullOrWhiteSpace($response.Content) -eq $false) { $message += "`r`n" + $response.Content }
            throw $message
        }
    }
}
end {
	return $results
}
}






[string[]]$funcs =
	"Get-MyGetUser", "Test-MyGetUserExists", "Get-MyGetUserFeeds", "New-MyGetUser", "Remove-MyGetUser"

Export-ModuleMember -Function $funcs