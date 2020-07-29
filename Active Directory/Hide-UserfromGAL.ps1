$disabledusers = Get-ADUser -Filter { Enabled -eq $false } -Properties * 

foreach ($user in $disabledusers) {
    $user = $user.sAMAccountName
    #Hide the user account from the Global address book
    Write-Host "`nHiding the user account " -NoNewline
    Write-Host "$user" -ForegroundColor Magenta -NoNewline
    Write-Host " from the Global Address List..." -NoNewline
    # Set the AD Hide From Address List Value to True
    try {
        Set-ADUser $user -Add @{msExchHideFromAddressLists = "TRUE" } -ErrorAction Stop
        Write-Host "Done" -ForegroundColor Green
    }
    catch {
        $ErrorMessage = $_.Exception.Message
        if ($ErrorMessage -notcontains "cannot be found on this object") {
            Write-Output ""
            Write-Warning $ErrorMessage
        }
    }
}