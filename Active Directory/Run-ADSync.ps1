Invoke-Command -ComputerName ADSync -ScriptBlock { Start-ADSyncSyncCycle -PolicyType Delta }
