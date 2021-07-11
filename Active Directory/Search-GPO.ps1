# Get the string we want to search for 
$string = 'Text Here'
 
# Set the domain to search for GPOs 
$DomainName = $env:USERDNSDOMAIN 
 
# Find all GPOs in the current domain 
Write-Host "Finding all the GPOs in $DomainName" 
Import-Module grouppolicy 
$allGposInDomain = Get-GPO -All -Domain $DomainName 
[string[]] $MatchedGPOList = @()

# Look through each GPO's XML for the string 
Write-Host 'Starting search....' 
foreach ($gpo in $allGposInDomain) { 
    $report = Get-GPOReport -Guid $gpo.Id -ReportType Xml 
    if ($report -match $string) { 
        Write-Host "********** Match found in: $($gpo.DisplayName) **********" -ForegroundColor 'Green'
        $MatchedGPOList += "$($gpo.DisplayName)";
    } # end if 
    else { 
        Write-Host "No match in: $($gpo.DisplayName)" 
    } # end else 
} # end foreach
Write-Host "`r`n"
Write-Host 'Results: **************' -ForegroundColor 'Yellow'
foreach ($match in $MatchedGPOList) { 
    Write-Host "Match found in: $($match)" -ForegroundColor 'Green'
}