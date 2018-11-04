# http://stackoverflow.com/questions/1183183/path-of-currently-executing-powershell-script
$root = Split-Path $MyInvocation.MyCommand.Path -Parent;

Import-Module MyGetUcsb -Force

Import-Module Pester

Describe "MyGetUcsb" {

	Context "Packages" {

        BeforeAll {
        }
		
		<#It "Move-MyGetPackage" {

            "todo" | Should Be "done"
        }#>
        
        <#It "Get-MyGetPackage" {
            $downloadPath = "$root\TestResources\"
            Get-MyGetPackage -Feed public -PackageName Ucsb.Sa.Enterprise.AspNet.WebApi.Client -Version 1.0.48987 -Destination $downloadPath

            Test-Path "$downloadPath\Ucsb.Sa.Enterprise.AspNet.WebApi.Client.1.0.48987.nupkg" | Should Be $true

            Remove-Item -Path "$downloadPath\Ucsb.Sa.Enterprise.AspNet.WebApi.Client.1.0.48987.nupkg"
        }#>

        <# THIS TEST SHOULD BE KEPT COMMENTED OUT UNTIL THE DELETE/REMOVE WORKS PROPERLY #>
        # It "Add-MyGetPackage" {
        #     Add-MyGetPackage -Feed internal-nonprod -Path "\\sa61\AllContent\Data\NuGetPackages\Ucsb.Sa.Enterprise.AspNet.WebApi.Client.1.0.49102.nupkg"
        # }

        AfterAll {
        }

	}
}