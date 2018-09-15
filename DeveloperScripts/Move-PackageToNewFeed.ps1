param(
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

import-module secretserverucsb
Import-Module MyGetUcsb
Import-Module CoreUcsb

# Set up credentials
$secret = get-secretserversecret -filter "myget.org - sist-ucsb" | where-object { $_.Id -eq 3386 }
$username = $secret.Username
$password = $secret.Password
$pwSecure = ConvertTo-SecureString $password -AsPlainText -Force
$credHeaderPair = "$($username):$($password)"
$cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $username, $pwSecure
$encodedCredentials = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($credHeaderPair))

# Set up local folder and download/delete uri's
$mygetBaseDlUrl = $global:MyGetUcsb.FeedUrlFormat -f $FromFeed
$mygetDlUrl = "{0}/{1}/{2}" -f $mygetBaseDlUrl, $PackageName, $Version
$mygetDeleteUrl = "{0}?hardDelete=true" -f $mygetDlUrl
$tempPath = [System.IO.Path]::GetTempPath()
$tempDlFolder = "{0}{1}.{2}" -f $tempPath, $PackageName, $Version
$tempDlPath = "{0}\{1}.{2}.nupkg" -f $tempDlFolder, $PackageName, $Version

# Create temporary local folder
if((Test-Path $tempDlFolder) -eq $false) { mkdir $tempDlFolder }

# Download the package to local disk
Invoke-WebRequest -Uri $mygetDlUrl -UseBasicParsing -OutFile $tempDlPath -Credential $cred -Verbose


# Push up the downloaded package to the new feed
$moduleBase = (Get-Module -Name MyGetUcsb).ModuleBase
$nuget = "{0}\Resources\nuget.exe" -f $moduleBase
$toFeedUrl = $global:MyGetUcsb.FeedUrlFormat -f $ToFeed
. $nuget push $tempDlPath -NonInteractive -Source $toFeedUrl -ApiKey $global:MyGetUcsb.ApiKey -NonInteractive -Verbosity Detailed


# Remove the package from the original feed
$fromFeedUrl = $global:MyGetUcsb.FeedUrlFormat -f $FromFeed
Invoke-WebRequest -Uri $mygetDeleteUrl -Method DELETE -Headers @{ Authorization = "Basic $encodedCredentials" } -Verbose


# Remove the temporary files from disk
if(Test-Path $tempDlFolder) { rmdir $tempDlFolder -Recurse -Verbose }

