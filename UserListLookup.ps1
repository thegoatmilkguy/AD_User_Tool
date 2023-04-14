Import-Module ActiveDirectory

$filepath = Read-Host -Prompt "Enther the path to a CSV file.  File format must have column names 'FirstName' and 'LastName'."

$users = Import-Csv -Path $filepath

foreach ($user in $users) {
    $firstName = $user.FirstName
    $lastName = $user.LastName
    $adUser = Get-ADUser -Filter {GivenName -like $firstName -and Surname -like $lastName}
    $user.SamAccountName = $adUser.SamAccountName
    Write-Output $firstName " " $lastName " " $adUser.SamAccountName
}
$users | Export-Csv -Path $filepath -NoTypeInformation