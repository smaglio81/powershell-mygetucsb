# http://stackoverflow.com/questions/1183183/path-of-currently-executing-powershell-script
$root = Split-Path $MyInvocation.MyCommand.Path -Parent;

Import-Module MyGetUcsb -Force

Import-Module Pester

Describe "MyGetUcsb" {

	Context "Packages" {

        BeforeAll {
        }
		
		It "Move-MyGetPackage" {

            "todo" | Should Be "done"
		}

        AfterAll {
        }

	}
}