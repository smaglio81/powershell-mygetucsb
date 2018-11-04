# This file shouldn't be run on it's own. It should be loaded using the MyGetUcsb Module.


<#
.SYNOPSIS
	Copies a package from one feed to another feed.

.PARAMETER FromFeed
	The feed to move the package from

.PARAMETER ToFeed
	The feed to move the package to

.PARAMETER PackageName
	The name of the package to move

.PARAMETER Version
	The version of the package to move

.EXAMPLE
	 Copy-MyGetPackage `
		 -FromFeed "public" `
		 -ToFeed "internal" `
		 -PackageName "Ucsb.Sa.Ssis.Sitefinity.StandardTemplatePackage" `
		 -Version "2.0.47166"
#>
Function Copy-MyGetPackage {
	[CmdletBinding()]
	param(
		[Parameter(Mandatory = $true, ValueFromPipeline = $true)]
		[ValidateSet("public","internal","internal-nonprod","arit")]
		[string] $FromFeed,
		[Parameter(Mandatory = $true, ValueFromPipeline = $true)]
		[ValidateSet("public","internal","internal-nonprod","arit")]
		[string] $ToFeed,
		[Parameter(Mandatory = $true, ValueFromPipeline = $true)]
		[string] $PackageName,
		[Parameter(Mandatory = $true, ValueFromPipeline = $true)]
		[string] $Version
	)
	
		Move-MyGetPackage `
			-FromFeed $FromFeed `
			-ToFeed $ToFeed `
			-PackageName $PackageName `
			-Version $Version `
			-SkipDelete:$true `
			-Verbose:$Verbose
	}


<#
.SYNOPSIS
	Moves a package from one feed to another feed.

.PARAMETER FromFeed
	The feed to move the package from

.PARAMETER ToFeed
	The feed to move the package to

.PARAMETER PackageName
	The name of the package to move

.PARAMETER Version
	The version of the package to move

.EXAMPLE
	 Move-MyGetPackage `
		 -FromFeed "public" `
		 -ToFeed "internal" `
		 -PackageName "Ucsb.Sa.Ssis.Sitefinity.StandardTemplatePackage" `
		 -Version "2.0.47166"
#>
Function Move-MyGetPackage {
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
    [ValidateSet("public","internal","internal-nonprod","arit")]
    [string] $FromFeed,
    [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
    [ValidateSet("public","internal","internal-nonprod","arit")]
    [string] $ToFeed,
    [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
    [string] $PackageName,
    [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
	[string] $Version,
	[switch] $SkipDelete
)

	# Set up local folder and download/delete uri's
	$tempDownloadPath = Get-MyGetTempDownloadFilename -PackageName $PackageName -Version $Version -Verbose:$Verbose

	# Download the package to local disk
	Get-MyGetPackage -Feed $FromFeed -PackageName $PackageName -Version $Version -Destination $tempDownloadPath -Verbose:$Verbose

	# Push up the downloaded package to the new feed
	Add-MyGetPackage -Feed $ToFeed -Path $tempDownloadPath -Verbose:$Verbose

	# Remove the package from the original feed
	if($SkipDelete -eq $false) {
		Remove-MyGetPackage -Feed $FromFeed -PackageName $PackageName -Version $Version -Verbose:$Verbose
	}

	# Remove the temporary files from disk
	$tempDownloadFolder = Split-Path -Path $tempDownloadPath -Parent
	if(Test-Path $tempDownloadFolder) { rmdir $tempDownloadFolder -Recurse -Verbose:$Verbose }
}


<#
.SYNOPSIS
	Downloads a prerelease package from MyGet, removes the prerelease flags and adds it back.

.PARAMETER Feed
	The feed that contains the packages

.PARAMETER PackageName
	The name of the package

.PARAMETER Version
	The version of the package

.PARAMETER Destination
	The destination to download to (can be a .nupkg file or directory)

.EXAMPLE
	 Get-MyGetPackage `
		 -Feed "public" `
		 -PackageName "Ucsb.Sa.Ssis.Sitefinity.StandardTemplatePackage" `
		 -Version "2.0.47166-prerelease"
#>
Function Get-MyGetPackage {
[CmdletBinding()]
param(
	[Parameter(Mandatory = $true, ValueFromPipeline = $true)]
	[ValidateSet("public","internal","internal-nonprod","arit")]
	[string] $Feed,
	[Parameter(Mandatory = $true, ValueFromPipeline = $true)]
	[string] $PackageName,
	[Parameter(Mandatory = $true, ValueFromPipeline = $true)]
	[string] $Version,
	[Parameter(Mandatory = $false, ValueFromPipeline = $true)]
	[string] $Destination = $root
)

	# setup directory to download to
	if($Destination.ToLower().EndsWith(".nupkg")) {
		$destPath = Split-Path -Path $Destination -Parent
		$destFile = $Destination
	} else {
		$destPath = $Destination
		$destFile = "{0}\{1}.{2}.nupkg" -f $destPath, $PackageName, $Version
	}
	if((Test-Path -Path $destPath) -eq $false) { mkdir -Path $destPath | Out-Null }

	# download file
	$feedUrl = $global:MyGetUcsb.FeedUrlFormat -f $Feed
	$packageUrl = "{0}/{1}/{2}" -f $feedUrl, $PackageName, $Version

	Invoke-WebRequest -Uri $packageUrl -UseBasicParsing -OutFile $destFile -Headers $global:MyGetUcsb.AuthHeader -Verbose:$Verbose
}



<#
.SYNOPSIS
	Uploads a nuget package to MyGet

.PARAMETER Feed
	The feed to upload to

.PARAMETER Path
	The path to the package

.EXAMPLE
	 Add-MyGetPackage `
		 -Feed "public" `
		 -Path "C:\Temp\Ucsb.Sa.Ssis.Sitefinity.StandardTemplatePackage.2.0.47166.nupkg"
#>
Function Add-MyGetPackage {
[CmdletBinding()]
param(
	[Parameter(Mandatory = $true, ValueFromPipeline = $true)]
	[ValidateSet("public","internal","internal-nonprod","arit")]
	[string] $Feed,
	[Parameter(Mandatory = $true, ValueFromPipeline = $true)]
	[string] $Path
)
	
	# Push up the downloaded package to the new feed
	#$moduleBase = (Get-Module -Name MyGetUcsb).ModuleBase
	#$nuget = "{0}\Resources\nuget.exe" -f $moduleBase
	$nuget = "$root\Resources\nuget.exe"
	$toFeedUrl = $global:MyGetUcsb.FeedUrlFormat -f $Feed
	if($Verbose) { $verbosity = "-Verbosity Detailed" } else { $verbosity = "" }
	
	. $nuget push $Path -Source $toFeedUrl -ApiKey $global:MyGetUcsb.ApiKey -NonInteractive $verbosity
	
}


<#
.SYNOPSIS
	Delete a package from a feed

.PARAMETER Feed
	The feed to remove the package from

.PARAMETER PackageName
	The name of the package to move

.PARAMETER Version
	The version of the package to move

.PARAMETER Unlist
	Should this package be unlisted instead of deleted. This is a "soft delete".

.EXAMPLE
	 Remove-MyGetPackage `
		 -Feed "public" `
		 -PackageName "Ucsb.Sa.Ssis.Sitefinity.StandardTemplatePackage" `
		 -Version "2.0.47166"
#>
Function Remove-MyGetPackage {
[CmdletBinding()]
param(
	[Parameter(Mandatory = $true, ValueFromPipeline = $true)]
	[ValidateSet("public","internal","internal-nonprod","arit")]
	[string] $Feed,
	[Parameter(Mandatory = $true, ValueFromPipeline = $true)]
	[string] $PackageName,
	[Parameter(Mandatory = $true, ValueFromPipeline = $true)]
	[string] $Version,
	[switch] $Unlist
)

	$mygetBaseDlUrl = $global:MyGetUcsb.FeedUrlFormat -f $Feed
	$mygetDeleteUrl = "{0}/{1}/{2}" -f $mygetBaseDlUrl, $PackageName, $Version

	if($Unlist -eq $false) {
		# this should be the detault path, the normal delete is a hard delete
		$mygetDeleteUrl = "{0}?hardDelete=true" -f $mygetDeleteUrl
	}
	$response = Invoke-WebRequest -Uri $mygetDeleteUrl -Method DELETE -Headers $global:MyGetUcsb.BasicAuthHeader -Verbose:$Verbose
	if($Verbose) { $response }
}

<#
.SYNOPSIS
	A wrapper for Remove-MyGetPackage that uses the -Unlist switch

.PARAMETER Feed
	The feed to unlist the package from

.PARAMETER PackageName
	The name of the package to move

.PARAMETER Version
	The version of the package to move

.EXAMPLE
	 Hide-MyGetPackage `
		 -Feed "public" `
		 -PackageName "Ucsb.Sa.Ssis.Sitefinity.StandardTemplatePackage" `
		 -Version "2.0.47166"
#>
Function Hide-MyGetPackage {
[CmdletBinding()]
param(
	[Parameter(Mandatory = $true, ValueFromPipeline = $true)]
	[ValidateSet("public","internal","internal-nonprod","arit")]
	[string] $Feed,
	[Parameter(Mandatory = $true, ValueFromPipeline = $true)]
	[string] $PackageName,
	[Parameter(Mandatory = $true, ValueFromPipeline = $true)]
	[string] $Version
)
	Remove-MyGetPackage -Feed $Feed -PackageName $PackageName -Version $Version -Unlist -Verbose:$Verbose
}


<#
.SYNOPSIS
	Downloads a prerelease package from MyGet, removes the prerelease flags and adds it back.

.PARAMETER Feed
	The feed that contains the packages

.PARAMETER ToFeed
	Use this to place the release package in a different feed

.PARAMETER PackageName
	The name of the package

.PARAMETER Version
	The version of the package

.EXAMPLE
	 ConvertTo-MyGetReleasePackage `
		 -Feed "public" `
		 -PackageName "Ucsb.Sa.Ssis.Sitefinity.StandardTemplatePackage" `
		 -Version "2.0.47166-prerelease"
#>
Function ConvertTo-MyGetReleasePackage {
[CmdletBinding()]
param(
	[Parameter(Mandatory = $true, ValueFromPipeline = $true)]
	[ValidateSet("public","internal","internal-nonprod","arit")]
	[string] $Feed,
	[Parameter(Mandatory = $true, ValueFromPipeline = $true)]
	[string] $PackageName,
	[Parameter(Mandatory = $true, ValueFromPipeline = $true)]
	[string] $Version,
	[Parameter(Mandatory = $false, ValueFromPipeline = $true)]
	[ValidateSet("public","internal","internal-nonprod","")]
	[string] $ToFeed = ""
)

	# Set up local folder and download/delete uri's
	$tempDownloadPath = Get-MyGetTempDownloadFilename -PackageName $PackageName -Version $Version

	# Download the package to local disk
	Get-MyGetPackage -Feed $Feed -PackageName $PackageName -Version $Version -Destination $tempDownloadPath -Verbose:$Verbose

	# Convert Package to Release Version
	$releasePath = ConvertTo-SaNuGetReleasePackage -Path $tempDownloadPath -Verbose:$Verbose

	# Push up the downloaded package to the new feed
	if($ToFeed -eq "") { $ToFeed = $Feed }
	Add-MyGetPackage -Feed $ToFeed -Path $releasePath -Verbose:$Verbose

	# Remove the temporary files from disk
	$tempDownloadFolder = Split-Path -Path $tempDownloadPath -Parent
	if(Test-Path $tempDownloadFolder) { rmdir $tempDownloadFolder -Recurse -Verbose:$Verbose }
}


<#
.SYNOPSIS
	Downloads a release package from MyGet, adds prerelease flags and adds it back. (This is used
	when you've messed up and need to "delist" a package quickly.)

.PARAMETER Feed
	The feed that contains the packages

.PARAMETER ToFeed
	Use this to place the release package in a different feed

.PARAMETER PackageName
	The name of the package

.PARAMETER Version
	The version of the package

.PARAMETER PrereleaseTag
	A prerelease tag name to give. (Default = 'prerelease')

.EXAMPLE
	 ConvertTo-MyGetPrereleasePackage `
		 -Feed "public" `
		 -PackageName "Ucsb.Sa.Ssis.Sitefinity.StandardTemplatePackage" `
		 -Version "2.0.47166" `
		 -PrereleaseTag "prerelease"
#>
Function ConvertTo-MyGetPrereleasePackage {
	[CmdletBinding()]
	param(
		[Parameter(Mandatory = $true, ValueFromPipeline = $true)]
		[ValidateSet("public","internal","internal-nonprod","arit")]
		[string] $Feed,
		[Parameter(Mandatory = $true, ValueFromPipeline = $true)]
		[string] $PackageName,
		[Parameter(Mandatory = $true, ValueFromPipeline = $true)]
		[string] $Version,
		[Parameter(Mandatory = $false, ValueFromPipeline = $true)]
		[string] $PrereleaseTag = "prerelease",
		[Parameter(Mandatory = $false, ValueFromPipeline = $true)]
		[ValidateSet("public","internal","internal-nonprod","")]
		[string] $ToFeed = ""
	)
	
		# Set up local folder and download/delete uri's
		$tempDownloadPath = Get-MyGetTempDownloadFilename -PackageName $PackageName -Version $Version -Verbose:$Verbose
	
		# Download the package to local disk
		Get-MyGetPackage -Feed $Feed -PackageName $PackageName -Version $Version -Destination $tempDownloadPath -Verbose:$Verbose
	
		# Convert Package to Release Version
		$prereleasePath = ConvertTo-SaNuGetPrereleasePackage -Path $tempDownloadPath -PrereleaseTag $PrereleaseTag -Verbose:$Verbose
	
		# Push up the downloaded package to the new feed
		if($ToFeed -eq "") { $ToFeed = $Feed }
		Add-MyGetPackage -Feed $ToFeed -Path $prereleasePath -Verbose:$Verbose
		
		# Remove the temporary files from disk
		$tempDownloadFolder = Split-Path -Path $tempDownloadPath -Parent
		if(Test-Path $tempDownloadFolder) { rmdir $tempDownloadFolder -Recurse -Verbose:$Verbose }
	}



Function Get-MyGetTempDownloadFilename {
[CmdletBinding()]
param(
	[Parameter(Mandatory = $true, ValueFromPipeline = $true)]
	[string] $PackageName,
	[Parameter(Mandatory = $true, ValueFromPipeline = $true)]
	[string] $Version
)

	# Set up local folder and download/delete uri's
	$tempPath = [System.IO.Path]::GetTempPath()
	$tempDlFolder = "{0}{1}.{2}" -f $tempPath, $PackageName, $Version
	$tempDlPath = "{0}\{1}.{2}.nupkg" -f $tempDlFolder, $PackageName, $Version

	return $tempDlPath
}



[string[]]$funcs =
	"Copy-MyGetPackage", "Move-MyGetPackage", "Remove-MyGetPackage", "Get-MyGetPackage", "Add-MyGetPackage", `
	"ConvertTo-MyGetReleasePackage", "ConvertTo-MyGetPrereleasePackage", "Hide-MyGetPackage"

Export-ModuleMember -Function $funcs