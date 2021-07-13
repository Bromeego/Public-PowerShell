# Import AD Module
Import-Module ActiveDirectory

# Create blank array to dump the user info into
$users = @()

# This is the date range we want to go back
$date = (Get-Date).AddDays(-90)

#######################################################
# Add the OU's we want to look at                     #
# e.g. 'OU=Users,OU=Building,DC=Business,DC=co,DC=nz' #
# for multiple add a comma (,) after each.            #
#######################################################
$searchbases = @(

)

# For each OU lets get all the info which is relevant and then out put it to a CSV
foreach ($OU in $searchbases) {
    $users += Get-ADUser -SearchBase $OU -Filter * -Properties * | `
            Where-Object { ($_.enabled -eq $True) -and ($_.lastlogondate -lt $date) } | `
            Select-Object Name, sAMAccountName, whenCreated, passwordlastset, passwordneverexpires, lastlogondate, physicalDeliveryOfficeName, Department | `
            Sort-Object lastlogondate
}

# Export to CSV
$users | Export-Csv 'c:\temp\UserLastLogin.csv' -NoTypeInformation