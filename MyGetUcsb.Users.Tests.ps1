# http://stackoverflow.com/questions/1183183/path-of-currently-executing-powershell-script
$root = Split-Path $MyInvocation.MyCommand.Path -Parent;

Import-Module MyGetUcsb -Force

Import-Module Pester

Describe "MyGetUcsb" {

	Context "RestMethod" {

        BeforeAll {
        }
		
		It "Get-MyGetUser" {

            # test one that exists
            $username = "maglio-s"
            
            $results = Get-MyGetUser -Username $username

            $results.name | Should Be "Steven Maglio"

            # test one that does not exist
            $usernameNotExists = $username + "aklasjdf"

            $results = Get-MyGetUser -Username $usernameNotExists

            $results | Should Be $null
            
		}
<#
        It "Get-MyGetUserFeeds" {

            $username = "maglio-s"
            
            $results = Get-MyGetUserFeeds -Username $username

            $results.name | Should Be "Steven Maglio"
		}


        It "New-MyGetUser | Remove-MyGetUser" {

            $username = "testapi_user"
            $name = "Test API"
            $email = "testapi-user@sa.ucsb.edu"

            # the user shouldn't be setup yet. If they are, remove them
            
            if(Test-MyGetUserExists -Username $username) {
                $null = Remove-MyGetUser -Username $username
            }
            

            # test out the new user
            $result = New-MyGetUser -Username $username -Name $name -Email $email

            $results.name | Should Be $name


            # remove the user
            $result = Remove-MyGetUser -Username $username

            $results.name | Should Be $name


            # verify the removal
            try {
                Get-MyGetUser -Username $username
            } catch {
                $_.Exception.Message | Should Be "The remote server returned an error: (404) Not Found."
            }

		}
#>

        AfterAll {
        }

	}
}