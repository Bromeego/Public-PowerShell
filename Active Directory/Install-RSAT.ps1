#Calling Powershell as Admin and setting Execution Policy to Bypass to avoid Cannot run Scripts error
([switch]$Elevated)
function CheckAdmin {
    $currentUser = New-Object Security.Principal.WindowsPrincipal $([Security.Principal.WindowsIdentity]::GetCurrent())
    $currentUser.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
}
if ((CheckAdmin) -eq $False) {
    if ($elevated) {
        # could not elevate, quit
    }
    else {
        Start-Process powershell.exe -Verb RunAs -ArgumentList ('-noprofile -ExecutionPolicy Bypass -file "{0}" -elevated' -f ($myinvocation.MyCommand.Definition))
    }
    Exit
}

# Small script to Install RSAT Tools for Windows 10 version 1809 and higher

$win10build = (Get-CimInstance Win32_OperatingSystem).Version

# Convert OS Version number to Windows 10 Build Number
switch ( $win10build ) {
    '10.0.10240' { 
        $build = "1507" 
    }
    '10.0.10586' { 
        $build = "1511" 
    }
    '10.0.14393' { 
        $build = "1607" 
    }
    '10.0.15063' { 
        $build = "1703" 
    }
    '10.0.16299' { 
        $build = "1709" 
    }
    '10.0.17134' { 
        $build = "1803" 
    }
    '10.0.17686' { 
        $build = "1809" 
    }
    '10.0.18362' { 
        $build = "1903" 
    }
    '10.0.18363' { 
        $build = "1909" 
    }
    '10.0.19041' { 
        $build = "2001" 
    }
    # If build number cannot be mapped throw out a warning
    Default {
        Write-Warning "Cannot find build number `n The build may have not been added to the script. Please review"
        Start-Sleep -Seconds 10
        Exit
    }
}

# Run the commands against the build we have installed
switch ( $build ) {
    '1709' { 
        Start-Process wusa.exe -ArgumentList "\\qrbak07\IT-Installs\Microsoft\RSAT\WindowsTH-RSAT_WS_1709-x64.msu", "/quiet", "/norestart" -wait 
    }
    '1803' { 
        Start-Process wusa.exe -ArgumentList "\\qrbak07\IT-Installs\Microsoft\RSAT\WindowsTH-RSAT_WS_1803-x64.msu", "/quiet", "/norestart" -wait 
    }
    { $_ -ge '1809' } {
        Write-Host "Setting Machine to not use WSUS... `n`n`n`n`n`n`n`n"
        # Stop the Windows Update service
        try {
            Stop-Service -Name wuauserv -ErrorAction Stop
        }
        Catch {
            $ErrorMessage = $_.Exception.Message
            Write-Warning "$ErrorMessage" 
        }
        # Remove the registry key
        try {
            Remove-Item HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate -Recurse -ErrorAction Stop
        }
        Catch {
            $ErrorMessage = $_.Exception.Message
            Write-Warning "$ErrorMessage"
        }
        # Start the Windows Update service
        try {
            Start-Service -name wuauserv -ErrorAction Stop
        }
        Catch {
            $ErrorMessage = $_.Exception.Message
            Write-Warning "$ErrorMessage" 
        }


        $Tools = Get-WindowsCapability -Name 'RSAT*' -Online

        foreach ($tool in $tools) {
            $RSATTool = $tool.Name
            $RSATOutput = $RSATTool -replace ".{11}$"
            Write-Host "Installing $RSATOutput... " -NoNewline
            try {
                Add-WindowsCapability -Name $RSATTool -Online | Out-Null
                Write-Host "Done" -ForegroundColor Green
            }
            catch {
                $ErrorMessage = $_.Exception.Message
                Write-Warning "$ErrorMessage"
            }              
        } 
    }
}

Read-Host "Press Enter to exit"