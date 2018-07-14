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

# Download the file to a temporary location

$mygetBaseDlUrl = $global:MyGetUcsb.FeedUrlFormat -f $FromFeed
$mygetDlUrl = "{0}/{1}/{2}" -f $mygetBaseDlUrl, $PackageName, $Version
$tempDlFolder = "{0}\{1}.{2}" -f $env:TEMP, $PackageName, $Version
$tempDlPath = "{0}\{1}.{2}.nupkg" -f $tempDlFolder, $PackageName, $Version

if((Test-Path $tempDlFolder) -eq $false) { mkdir $tempDlFolder }

# actually download
Invoke-WebRequest -Uri $mygetDlUrl -UseBasicParsing -OutFile $tempDlPath -Verbose



# Push up the file to the new feed

$moduleBase = (Get-Module -Name MyGetUcsb).ModuleBase
$nuget = "{0}\Resources\nuget.exe" -f $moduleBase
$toFeedUrl = $global:MyGetUcsb.FeedUrlFormat -f $ToFeed

. $nuget push $tempDlPath -NonInteractive -Source $toFeedUrl -ApiKey $global:MyGetUcsb.ApiKey -NonInteractive -Verbosity Detailed



# Remove the file from the original feed

$fromFeedUrl = $global:MyGetUcsb.FeedUrlFormat -f $FromFeed

. $nuget delete $PackageName $Version -ApiKey $global:MyGetUcsb.ApiKey -Source https://sist-ucsb.myget.org/F/public/api/v3/index.json -NonInteractive -Verbosity Detailed



# Remove the temporary files from disk

if(Test-Path $tempDlFolder) { rmdir $tempDlFolder -Recurse -Verbose }


