# http://stackoverflow.com/questions/1183183/path-of-currently-executing-powershell-script
$root = Split-Path $MyInvocation.MyCommand.Path -Parent;

# grab functions from files (from C:\Chocolatey\chocolateyinstall\helpers\chocolateyInstaller.psm1)
Resolve-Path $root\MyGetUcsb.*.Tests.ps1 |
    % { . $_.ProviderPath }

