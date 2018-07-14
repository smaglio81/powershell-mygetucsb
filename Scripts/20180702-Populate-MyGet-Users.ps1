Import-Module MyGetUcsb -Force
Import-Module ActiveDirectory

$developers = Get-ADGroupMember -Identity "Developers"
$domainAdmins = Get-ADGroupMember -Identity "Domain Admins"

$dgl = $developers |? { $domainAdmins.SamAccountName -notcontains $_.SamAccountName }
$dgl = $dgl |? { $_.name -notmatch "- Admin" }
$dgl = $dgl |? { @("names", "of", "people") -notcontains $_.name }

$dgl | ft -AutoSize
$dgl.Count

$users = @()
foreach($d in $dgl) {
    $nameSplit = $d.name.Split(" ", [StringSplitOptions]::RemoveEmptyEntries)
    $email = "{0}.{1}@sa.ucsb.edu" -f $nameSplit[0], $nameSplit[$nameSplit.Count - 1]
    $email = $email.ToLower()

    $user = New-Object PSCustomObject -Property @{
        Username = $d.SamAccountName.ToLower();
        Name = $d.name;
        Email = $email
    }
    $users += @($user)
}

$users | ft -AutoSize
$users.Count

Import-Module PowerShellLogging
$log = Enable-LogFile -Path D:\Projects\Dev\Enterprise\Powershell\MyGetUcsb\Scripts\20180702-Populate-MyGet-Users.log
try {
    foreach($user in $users) {
        New-MyGetUser -Username $user.Username -Name $user.Name -Email $user.Email
        Set-MyGetFeedUserPrivilege -Feed public -Username $user.Username -Privilege FeedContributor
        Set-MyGetFeedUserPrivilege -Feed internal -Username $user.Username -Privilege FeedContributor
        Set-MyGetFeedUserPrivilege -Feed internal-nonprod -Username $user.Username -Privilege FeedContributor
    }
} finally {
    $log | Disable-LogFile
}