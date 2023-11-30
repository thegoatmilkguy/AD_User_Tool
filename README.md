# AD_User_Tool
This is a tool I wrote out of a desire to learn PowerShell and to organize some tools and functions to help me work with Active Directory.
All functions are targeted at actions on users.  Below is a least of current features:
The script begins by helping look for your user.  It prompts for a first and last name.  If a field is left blank, a wildcard is used to find anyone with one of the two name paramters.  For example if you input "John" for the first name but leave the last name blank, it will return all users with the first name "John" in a menu and let you input a number to select the one you want from a menu.

From this point, all items in the script are focused on the previously selected user.  Another menu is displayed that gives the following options:
1.  Print user details
    -This option runs get-aduser and selects a few basic options that you might want to see like last logon date, if the account is locked or not, account email address, etc
2.  Print all user properties
    -This prints all properties for the user
3.  Check user lockout status
    -This runs a loop to check every domain controller if the user is locked out.  This can sometimes be helpful if a user was just locked out as it may give clues about what might have caused the lockout.
4.  Show user group count and memberships
    -This displays a count of the groups this user is in (helpful in diagnosing token size issues) and prints all the group memberships.
5.  Compare user group memberships
    -This compares all groups this user is a member of to another user after prompting for the user to compare against.
6.  Unlock user account
    -This unlocks the user's account
7.  Set a new temp password for user
    -This generates a random password, displays it for you to record, and resets the user's password to this new random string while setting the "ChangePasswordAtLogon" flag to "true."
8.  Select a new user account
    -This prompts for a new user and re-prints the menu.  All functions will now focus around this newly selected user account.
9.  Exit
    -This exits the script
