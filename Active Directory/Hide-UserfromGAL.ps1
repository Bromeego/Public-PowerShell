# Update GALs
$UpdateGALs = $false

# Create an empty array
$disabledusers = @()

#######################################################
# Add the OU's we want to look at                     #
# e.g. 'OU=Users,OU=Building,DC=Business,DC=co,DC=nz' #
#######################################################
$Searchbase = @(

)

# For each OU run the following command and add it into the array, this is OU recursive
# If you dont want recurse to happen then add -SearchScope OneLevel after -SearchBase $OU
foreach ($OU in $Searchbase) {
    $disabledusers += Get-ADUser -SearchBase $OU -SearchScope OneLevel -Filter { Enabled -eq $false } -Properties * |`
            Where-Object msExchHideFromAddressLists -NE 'TRUE' | `
            Select-Object sAMAccountName, Name, lastlogondate, msExchHideFromAddressLists
}

if ($UpdateGALs -eq $true) {
    foreach ($user in $disabledusers) {
        $user = $user.sAMAccountName
        #Hide the user account from the Global address book
        Write-Host "`nHiding the user account " -NoNewline
        Write-Host "$user" -ForegroundColor Magenta -NoNewline
        Write-Host ' from the Global Address List...' -NoNewline
        # Set the AD Hide From Address List Value to True
        try {
            Set-ADUser $user -Replace @{msExchHideFromAddressLists = 'TRUE' } -ErrorAction Stop
            Write-Host 'Done' -ForegroundColor Green
        }
        catch {
            $ErrorMessage = $_.Exception.Message
            if ($ErrorMessage -notcontains 'cannot be found on this object') {
                Write-Output ''
                Write-Warning $ErrorMessage
            }
        }
    }
}
else {
    Write-Output 'If you want the GAL change to happen, please change Line 2 to $true' 
}

# Export a list of all users which were/will be changed if a rollback is needed. 
$disabledusers | Export-Csv 'C:\temp\DisabledUsersShowinginGAL.csv' -NoTypeInformation