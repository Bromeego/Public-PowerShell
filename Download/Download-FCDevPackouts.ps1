# Fill out our variables
$Credential = New-Object -TypeName PSCredential -ArgumentList @('EPDev-FreshCool-Web\$EPDev-FreshCool-Web', (ConvertTo-SecureString -String 'fliHrB9nytrkonqJPPp45RLcswohMKwXPi9Brya45DK3hap6rwllHxtEwugp' -AsPlainText -Force))
$FTPHost = 'waws-prod-sy3-029.ftp.azurewebsites.windows.net'
$FTPPathBase = '/site/wwwroot/App_Data/Reports'

# Import the WinSCP Module and throw an error if it fails
Try{
    Import-Module -Name WinSCP -Force -ErrorAction 'Stop'
}
Catch{
    Write-Error 'Failed to Import Module'
    Throw $_
}

# Create a new session in WinSCP with the variables we set up 
$Session = New-WinSCPSession -SessionOption (New-WinSCPSessionOption -Credential $Credential -HostName $FTPHost -Protocol Ftp)

# Get the contents of the folder as there may be more than 1 Packout in there
$Packouts = Get-WinSCPChildItem -WinSCPSession $session -Path $FTPPathBase -Recurse

# Download the Packouts to the destination and remove the file from the FTP Server 
foreach ($Packout in $Packouts){
    $PackoutName = $Packout.Name
    Receive-WinSCPItem -WinSCPSession $session -Path "$FTPPathBase/$PackoutName" -Destination "E:\Packouts\Test\$PackoutName" -Remove
}
