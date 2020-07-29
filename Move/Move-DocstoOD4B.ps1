#Company name e.g. We Build Plans Limited
$CompName = ""

Write-Host "Moving Documents Folder"
Move-Item -Path "$env:USERPROFILE\Documents\*" -Destination "$env:USERPROFILE\OneDrive - $CompName\My Documents\" -Force -Verbose -ErrorAction SilentlyContinue
Write-Host -ForegroundColor Green "Documents Folder Move Completed"
Start-Sleep -s 1

Write-Host "`nMoving Documents Folder"
Move-Item -Path "$env:USERPROFILE\Downloads\*" -Destination "$env:USERPROFILE\OneDrive - $CompName\My Documents\Downloads" -Force -Verbose -ErrorAction SilentlyContinue
Write-Host -ForegroundColor Green "Downloads Folder Move Completed"
Start-Sleep -s 1

Write-Host "`nMoving Favourites Folder"
Move-Item -Path "$env:USERPROFILE\Favorites\*" -Destination "$env:USERPROFILE\OneDrive - $CompName\My Documents\Favorites" -Force -Verbose -ErrorAction SilentlyContinue
Write-Host -ForegroundColor Green "Favourites Folder Move Completed"
Start-Sleep -s 1

Write-Host "`nMoving Music Folder"
Move-Item -Path "$env:USERPROFILE\Music\*" -Destination "$env:USERPROFILE\OneDrive - $CompName\My Documents\Music" -Force -Verbose -ErrorAction SilentlyContinue
Write-Host -ForegroundColor Green "Music Folder Move Completed"
Start-Sleep -s 1

Write-Host "`nMoving Pictures Folder"
Move-Item -Path "$env:USERPROFILE\Pictures\*" -Destination "$env:USERPROFILE\OneDrive - $CompName\My Documents\Pictures" -Force -Verbose -ErrorAction SilentlyContinue
Write-Host -ForegroundColor Green "Pictures Folder Move Completed"
Start-Sleep -s 1

Write-Host "`nMoving Videos Folder"
Move-Item -Path "$env:USERPROFILE\Videos\*" -Destination "$env:USERPROFILE\OneDrive - $CompName\My Documents\Videos" -Force -Verbose -ErrorAction SilentlyContinue
Write-Host -ForegroundColor Green "Videos Folder Move Completed"

Pause
