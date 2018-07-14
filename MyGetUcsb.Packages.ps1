# This file shouldn't be run on it's own. It should be loaded using the MyGetUcsb Module.


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
Param (
    [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
    [ValidateSet("public","internal","internal-nonprod")]
    [string] $FromFeed,
    [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
    [ValidateSet("public","internal","internal-nonprod")]
    [string] $ToFeed,
    [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
    [string] $PackageName,
    [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
    [string] $Version
)

	throw (
		"This is still under development at \DeveloperScripts\Move-PackageToNewFeed.ps1. Currently, " +
		"deleting the package from the original feed is not working. But, it will copy it over without " +
		"any problems. (BTW, it reports that the delete should have worked, but the web interface
		doesn't show the package as deleted.)"
	)
	
}


[string[]]$funcs =
	"Move-MyGetPackage"

Export-ModuleMember -Function $funcs