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

function Group_Counter($username) {
    $groups = Get-ADPrincipalGroupMembership -Identity $username
    $groupcount = ($groups | Measure-Object).Count
    Write-Output $groups | Select-Object Name | Format-Table
    Write-Output "$username is in $groupcount groups."
}

function Set-RandomADPassword {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Username,
        [int]$Length = 15
    )
    try {
        $password = -join (48..57 + 65..90 + 97..122 | Get-Random -Count $Length | ForEach-Object{[char]$_})
        $secpasswd = ConvertTo-SecureString $password -AsPlainText -Force
        Write-Output "Temp password set to: $password"
        Set-ADAccountPassword -Identity $Username -Reset -NewPassword $secpasswd
        Set-Aduser -Identity $Username -ChangePasswordAtLogon $true
        Write-Host "Password changed successfully for user: $Username"
    } catch {
        Write-Host "Error changing password for user: $Username" -ForegroundColor Red
        Write-Error $_
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
    #print list of each entry in Active Directory based on the above search parameters
    foreach ($userList in (Get-ADUser -Filter { (givenname -like $firstname -and surname -like $lastname) })) {
        $menuArray += , $userList
        Write-host "$userCounter. $($menuArray[$userCounter-1].givenname) $($menuArray[$userCounter-1].surname), $($menuArray[$userCounter-1].SamAccountName)"
        $userCounter++
    }

    do { 
        [int]$menuSelection = Read-Host "`n Enter Option Number" 
    }
    until ([int]$menuSelection -le $userCounter - 1)

    $userID = $MenuArray[$menuSelection - 1]
    
    
    return $userID
}


#Clear the screen
Clear-Host

#set up usercounter, menuArray, and loop check for later
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
    Write-Host "4. Show user group count and memberships"
    Write-Host "5. Unlock user account"
    Write-Host "6. Set a new temp password for user"
    Write-Host "7. Select a new user account"
    Write-Host "8. Exit"

    
    [int]$selection = Read-Host "`n Enter your selection"
    
    Switch ($selection) {
        1 {
            Get-ADUser $user.SamAccountName -Properties * | Select-Object LastLogonDate, LockedOut, AccountLockoutTime, BadPwdcount, CN, GivenName, SurName, Title, Created, EmailAddress, EmployeeID, EmployeeType, Enabled, extensionAttribute5
        }
        2 {
            Get-ADUser $user.SamAccountName -Properties *
        }
        3 {
            Check_UserLockoutStatus $user.SamAccountName
        }
        4 {
            Group_Counter $user.SamAccountName
        }
        5 {
            Unlock-ADAccount -Identity $user.SamAccountName
            Write-Host "$user should now be unlocked"
        }
        6 {
            Set-RandomADPassword $user
        }
        7 {
            $user = Get_UserList
        }
        8 {
            Write-Host "`nFare thee well..."
            $loop = $false
            break
        }
        default {
            Write-Host "Invalid selection.  Please try again."
        }
        
    }
    
}