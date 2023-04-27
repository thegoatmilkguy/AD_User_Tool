#This script reads from a list of first names and last names and adds the SamAccountName for each entry it finds a match for in Active Directory

Import-Module ActiveDirectory

#Prompt for CSV file that has list of firstnames and lastnames
$filepath = Read-Host -Prompt "Enter the path to a CSV file.  File format must have column names 'FirstName' and 'LastName'."

$users = Import-Csv -Path $filepath

foreach ($user in $users) {
    $firstName = $user.FirstName
    $lastName = $user.LastName
    $adUser = Get-ADUser -Filter {GivenName -like $firstName -and Surname -like $lastName}
    $user.SamAccountName = $adUser.SamAccountName
    Write-Output $firstName " " $lastName " " $adUser.SamAccountName
}

#export data to the CSV file
$users | Export-Csv -Path $filepath -NoTypeInformation
