
$UserCredential = Get-Credential -Message 'Enter in your O365 account details "fristname.lastname@eastpack.co.nz"'
$ExchangeSession = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $UserCredential -Authentication Basic -AllowRedirection -ErrorAction Stop
Import-PSSession $ExchangeSession -AllowClobber | Out-Null

# Grab a list of all disabled user accounts from AD
$disabledusers = Get-ADUser -Filter { Enabled -eq $false } | Select-Object samaccountname

# Set UPN
$upn = ""

# Run the commands against each user
foreach ($user in $disabledusers) {
    $user = $user.samaccountname
    $upn = "$user@$upn"
    Try {
        $O365Licenses = (Get-MsolUser -UserPrincipalName $upn -ErrorAction Stop).licenses.AccountSkuId
    }
    catch {
        $ErrorMessage = $_.Exception.Message
        Write-Warning "$ErrorMessage"
    }
    if ($ErrorMessage -eq $null) {
        Write-Output "Removing Office 365 Licenses for $upn"
                
        foreach ($license in $O365Licenses) {
            Try {
                #Set-MsolUserLicense -UserPrincipalName $upn -RemoveLicenses $license -ErrorAction Stop
                Write-Host "Removed $license for $upn"
            }
            Catch {
                $ErrorMessage = $_.Exception.Message
                Write-Warning $errormessage
            }
        }

        # Convert the mailbox to shared
        Try {
            Write-Host "Setting $upn to a shared mailbox"
            #Set-Mailbox -identity $upn -Type Shared -ErrorAction Stop
        }
        Catch {
            $ErrorMessage = $_.Exception.Message
            Write-Warning "$ErrorMessage"
        }

        # Find the Office 365 Distribution Groups and remove the user from them
        try {
            $O365DistributionGroups = Get-DistributionGroup | Where-Object { (Get-DistributionGroupMember $_.Name | ForEach-Object { $_.PrimarySmtpAddress }) -contains "$upn" } | Select-Object -ExpandProperty name
        }
        catch {
            $ErrorMessage = $_.Exception.Message
            Write-Warning $errormessage
        }
        foreach ($O365DistGroup in $O365DistributionGroups) {
            try {
                #Remove-DistributionGroupMember -Identity $O365DistGroup -Member $upn -Confirm:$False -ErrorAction Stop
                Write-Host "Removed $upn from $O365DistGroup"
            }
            catch {
                $ErrorMessage = $_.Exception.Message
                Write-Warning $errormessage
            }
        }
    }
}
    