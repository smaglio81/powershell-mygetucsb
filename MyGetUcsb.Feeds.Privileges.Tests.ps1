# http://stackoverflow.com/questions/1183183/path-of-currently-executing-powershell-script
$root = Split-Path $MyInvocation.MyCommand.Path -Parent;

Import-Module MyGetUcsb -Force

Import-Module Pester

Describe "MyGetUcsb" {

	Context "Feeds - Privileges" {

        BeforeAll {
            $feed = "internal"
            $username = "testapi_privileges"

            if((Test-MyGetUserExists -Username $username) -eq $false) {
                $user = New-MyGetUser -Username "testapi_privileges" -Email "testapi_privileges@sa.ucsb.edu" -Name "testapi privileges"
            } else {
                $user = Get-MyGetUser -Username $username
            }
        }
		
		It "Get-MyGetFeedPrivilege" {

            $results = Get-MyGetFeedPrivilege -Feed $feed

            $results.id | Should Be $feed
            $results.links[0].url | Should Be "https://sist-ucsb.myget.org/_api/v1/feed/internal"

            # just checking it doesn't throw an exception
            $results = Get-MyGetFeedPrivilege -Feed $feed -IncludeInvites

		}

        It "New-MyGetFeedUserPrivilege" {

            $privilege = "Consumer"

            New-MyGetFeedUserPrivilege -Feed $feed -Username $user.username -Privilege $privilege

            $results = Get-MyGetFeedPrivilege -Feed $feed

            $result = $results.privileges |? { $_.username -eq $user.username }

            $result | Should Not Be $null
            $result.privilege | Should Be $privilege
            
		}


        AfterAll {
            if(Test-MyGetUserExists -Username $user.username) {
                $user | Remove-MyGetUser
            }
        }

	}
}