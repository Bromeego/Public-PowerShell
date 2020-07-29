# Export path
$path = "C:\temp\"
$Filename = "DHCPScopes.csv"

<# Populate the list of servers below 
e.g
$DHCPServers = @(
    "Server01",
    "server02",
    "Jimbo33"
)
#>

$DHCPServers = @(
    "",
    "",
    ""
)

foreach ($server in $DHCPServers) {
    Get-DhcpServerv4Scope -ComputerName $server | `
            Export-Csv "$path$filename" -NoTypeInformation -Append
}