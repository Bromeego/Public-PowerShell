$userSID = ""
 
# Translate the SID to a User Account
$objSID = New-Object System.Security.Principal.SecurityIdentifier ( $userSID)
try {
    $objUser = $objSID.Translate( [System.Security.Principal.NTAccount])
    Write-Host -Foreground Yellow -Background Black "$objUser"
}
# If SID cannot be Translated, Throw out the SID instead of error
catch {
    $objUser = $objSID.Value
    Write-Host -Foreground Yellow -Background Black "$objUser"
}
