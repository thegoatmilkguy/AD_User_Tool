Import-Module ActiveDirectory

function Check_UserLockoutStatus($username) {
    # Get a list of all domain controllers
    $domainControllers = Get-ADDomainController -Filter *

    # Iterate through the list of domain controllers
    foreach ($dc in $domainControllers) {
        # Get the user object for the specified username
        $user = Get-ADUser -Identity $username -Server $dc.Name
        # Check the LockoutTime attribute
        if (!$user.LockoutTime) {
            # User is not locked out on this domain controller
            Write-Output "$username is not locked out on domain controller $($dc.Name)."
        }
        else {
            # User is locked out on this domain controller
            Write-Output "$username is locked out on domain controller $($dc.Name)."
        }
    }
}

function Get_UserList {
    #prompt for first name
    $firstname = Read-Host -Prompt "Input user first name"
    if (!$firstname) {
        $firstname = "*"
    }

    #prompt for last name
    $lastname = Read-Host -Prompt "Input user last name"
    if (!$lastname) {
        $lastname = "*"
    }
    foreach ($userList in (Get-ADUser -Filter { (givenname -like $firstname -and surname -like $lastname) })) {
        $menuArray += , $userList
        Write-host "$userCounter. $($menuArray[$userCounter-1].givenname); $($menuArray[$userCounter-1].surname)"
        #Write-Host "$userCounter. $($userList[$userCounter-1].SamAccountName); $($userList[$userCounter-1].givenname) $($userList[$userCounter-1].surname)"
        $userCounter++
    }

    do { 
        [int]$menuSelection = Read-Host "`n Enter Option Number" 
    }
    until ([int]$menuSelection -le $userCounter - 1)

    $userID = $MenuArray[$menuSelection - 1]

    return $userID
}



Clear-Host

$userCounter = 1
$menuArray = @()
$loop = $true

$user = Get_UserList


while ($loop) {
    #Display Menu Options
    Write-Host "`n`nPlease select an action:"
    Write-Host "1. Print user details"
    Write-Host "2. Print all user properties"
    Write-Host "3. Check user lockout status on all domain controllers"
    Write-Host "4. Show user group memberships"
    Write-Host "5. Unlock user account"
    Write-Host "6. Select a new user account"
    Write-Host "7. Exit"

    
    [int]$selection = Read-Host "`n Enter your selection"
    
    Switch ($selection) {
        1 {
            Get-ADUser $user.SamAccountName -Properties * | Select-Object AccountLockoutTime, BadPwdcount, CN, GivenName, SurName, Title, Created, EmailAddress, EmployeeID, EmployeeType, Enabled, extensionAttribute5, lastLogonDate, LockedOut
        }
        2 {
            Get-ADUser $user.SamAccountName -Properties *
        }
        3 {
            Check_UserLockoutStatus $user.SamAccountName
        }
        4 {
            Get-ADPrincipalGroupMembership $user.SamAccountName | Select-Object name | Format-Table
        }
        5 {
            Unlock-ADAccount -Identity $user.SamAccountName
            Write-Host "$user should now be unlocked"
        }
        6 {
            $user = Get_UserList
        }
        7 {
            Write-Host "`nFare thee well..."
            $loop = $false
            break
        }
        default {
            Write-Host "Invalid selection.  Please try again."
        }
        
    }
    
}