Set-ExecutionPolicy Unrestricted

# Import the Skype Online Module
try {
    Import-Module SkypeOnlineConnector -ErrorAction Stop
}
catch {
    Write-Host "Cannot find the SkypeOnlineConnector, please download it from https://www.microsoft.com/en-us/download/details.aspx?id=39366"
    $errormessage = $true
}

#Import the MSOnline Module
try {
    Import-Module MSOnline -ErrorAction Stop
}
catch {
    Write-Host "Cannot the MSOnline Module"
    Install-Module MSOnline
}

if ($errormessage -ne $true) {
    # Add Office365 Credentials so we can pass it on to the Exchange connection and the Connect-MsolService
    $cred = Get-Credential -Message "Enter your Office365 Admin credentials"

    # Create new Office365 session with your credentials
    $sess = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $cred -Authentication Basic -AllowRedirection
    # Import the session
    Import-PSSession $sess -AllowClobber

    # Connect to MSOline with admin details
    Connect-MsolService -Credential $cred

    # Define the variables
    $identity = Read-Host -Prompt 'Enter Mailbox Identity (eg WasherRDBoardRoom)'
    $acctpwd = Read-Host -Prompt 'Enter new room password (must meet minimum requirements)'

    $Mailboxinfo = Get-Mailbox -Identity $identity
    $Mailboxupn = $mailboxinfo.WindowsEmailAddress
    $MailboxAlias = $mailboxinfo.Alias
    $MailboxIdentity = $mailboxinfo.Identity

    # Enable Room mailbox account and set the defined password
    try {
        Set-Mailbox -Identity $MailboxAlias -EnableRoomMailboxAccount $true -RoomMailboxPassword (ConvertTo-SecureString -String $acctpwd -AsPlainText -Force) -ErrorAction Stop
        Set-Mailbox -Identity $MailboxAlias -MailTip "This room is equipped to support Skype for Business Meetings"
        Write-Host "$MailBboxAlias has been set with the password of $acctpwd"
    }
    catch {
        $SetPasswordErrorMessage = $_.Exception.Message
        Write-Warning $SetPasswordErrorMessage
    }
    
    try {
        # Set auto accept on the mailbox 
        Set-CalendarProcessing -Identity $MailboxAlias -AutomateProcessing AutoAccept -AddOrganizerToSubject $false -AllowConflicts $false -DeleteComments $false -DeleteSubject $false -RemovePrivateProperty $false -ErrorAction Stop
        # Set the response 
        Set-CalendarProcessing -Identity $MailboxAlias -AddAdditionalResponse $true -AdditionalResponse "Your meeting is now scheduled and if it was enabled as a Skype Meeting will provide a seamless click-to-join experience from the conference room." -ErrorAction Stop
        Write-Host "$MailboxAlias is now set to Auto Accept invites and the response has been set"
    }
    catch {
        $SetCalendarErrorMessage = $_.Exception.Message
        Write-Warning $SetCalendarErrorMessage
    }

    # Set the Room account password to never expire
    try {
        Set-MsolUser -UserPrincipalName $Mailboxupn -PasswordNeverExpires $true -ErrorAction Stop
        Write-Host "$MailboxAlias password set to never expire"
    }
    catch {
        $SetExpiryErrorMessage = $_.Exception.Message
        Write-Warning $SetExpiryErrorMessage
    }

    # Get the Licenses for the defined account
    $UserLicense = (Get-MsolUser -UserPrincipalName $Mailboxupn).licenses
    if ($UserLicense -like "*STANDARDPACK*") {
        try {
            # Set the UsageLocation to NZ
            Set-MsolUser -UserPrincipalName $Mailboxupn -UsageLocation "NZ" -ErrorAction Stop
            # Add the Standard License (E1)
            Set-MsolUserLicense -UserPrincipalName $Mailboxupn -AddLicenses eastpack:STANDARDPACK -ErrorAction Stop
            Write-Host "$Mailboxupn now has a Standard (E1) License attached"
        }
        catch {
            $SetLicenseMessage = $_.Exception.Message
            Write-Warning $SetLicenseMessage
        }
    }
    else {
        Write-Host "$Mailboxupn has the following licenses $($Userlicense.AccountSKUID)"
    }

    # Check to see if the account is on Office 365, if it is not then migrate it over.
    # Create a new session with the creditials we provided 
    $cssess = New-CsOnlineSession -Credential $cred
    # Import the session
    Import-PSSession $cssess -AllowClobber
    # Get account information and check that it is on Prem, if it is. Migrate it to Office365.
    Write-Host "Checking that $MailboxIdentity is on Office365" -NoNewline
    $IsonOffice365 = Get-CsOnlineUser -Identity $MailboxIdentity | Select-Object -Expand RegistrarPool

    if ($IsonOffice365 -notlike "*infra.lync.com") {
        # Enable the meeting room and assign it to a Registrar Pool 
        try {
            Enable-CsMeetingRoom -Identity $MailboxIdentity -RegistrarPool "sippoolme1au103.infra.lync.com" -SipAddressType EmailAddress -ErrorAction Stop
            Write-Host -ForegroundColor Green " Done"
            Write-Host "$MailboxIdentity has been migrated to Office365 using $IsonOffice365"
        }
        catch {
            $EnableMeetingRoomMessage = $_.Exception.Message
            Write-Warning $EnableMeetingRoomMessage
        }
    }
    else {
        Write-Host "    The account is already on Office365, No need to migrate"
    }

    Read-Host "Migration is complete. Press enter to close the PowerShell window"

    # Remove the PowerShell session
    Get-PSSession | Remove-PSSession
}
else {
    Write-Host "You need to install the modules before we can run this script"
}
