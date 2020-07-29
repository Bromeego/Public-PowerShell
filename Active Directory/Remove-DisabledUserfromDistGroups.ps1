# Grab a list of all disabled user accounts from AD
$disabledusers = Get-ADUser -Filter { Enabled -eq $false } | Select-Object samaccountname

# Run the commands against each user
foreach ($user in $disabledusers) {
    $user = $user.samaccountname
    # Find the Distribution Groups which the user is a member of
    $distgroups = Get-ADUser -Identity $user | Get-ADPrincipalGroupMembership | Where-Object GroupCategory -EQ 'Distribution' | Select-Object -ExpandProperty name
    # Run the Remove-ADGroupMember against each group which the user is in
    foreach ($dist in $distgroups) {
        Get-ADGroup -Identity $dist | Remove-ADGroupMember -member $user -Confirm:$False
        Write-Output "Removed $user from $dist"
    }
}