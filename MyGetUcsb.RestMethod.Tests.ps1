# http://stackoverflow.com/questions/1183183/path-of-currently-executing-powershell-script
$root = Split-Path $MyInvocation.MyCommand.Path -Parent;

Import-Module MyGetUcsb -Force

Import-Module Pester

Describe "MyGetUcsb" {

	Context "RestMethod" {

        BeforeAll {
        }
		
		It "Invoke-MyGetRest" {

            $username = "maglio-s"
            $path = "/user/$username"

            $results = Invoke-MyGetRest -ApiPath $path

            $results.name | Should Be "Steven Maglio"
		}

        It "Invoke-MyGetRequest" {

            $username = "maglio-s"
            $path = "/user/$username"

            $results = Invoke-MyGetRequest -ApiPath $path

            $results.StatusCode | Should Be 200
            $jsonResults = $results.Content | ConvertFrom-Json
            $jsonResults.name | Should Be "Steven Maglio"

		}

        AfterAll {
        }

	}
}