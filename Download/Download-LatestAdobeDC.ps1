# Insert download folder
$DownloadFolder = ""

# Destination Folder
$DestinationFolder = ""

# Adobe FTP URL
$FTPFolderUrl = "ftp://ftp.adobe.com/pub/adobe/reader/win/AcrobatDC/"

#connect to ftp, and get directory listing
$FTPRequest = [System.Net.FtpWebRequest]::Create("$FTPFolderUrl") 
$FTPRequest.Method = [System.Net.WebRequestMethods+Ftp]::ListDirectory
$FTPResponse = $FTPRequest.GetResponse()
$ResponseStream = $FTPResponse.GetResponseStream()
$FTPReader = New-Object System.IO.Streamreader -ArgumentList $ResponseStream
$DirList = $FTPReader.ReadToEnd()

#from Directory Listing get last entry in list, but skip one to avoid the 'misc' dir
$LatestUpdate = $DirList -split '[\r\n]' | Where-Object { $_ } | Select-Object -Last 1 -Skip 1

#build file name
$LatestFile = "AcroRdrDCUpd" + $LatestUpdate + ".msp"

#build download url for latest file
$DownloadURL = "$FTPFolderUrl$LatestUpdate/$LatestFile"

# Get the name of the current Adobe Reader file
$CurrentItemName = Get-ChildItem -Path "$DownloadFolder" | Select-Object Name
$currentItem = $CurrentItemName.Name

# Compaire the two file names. If there is any difference then we will download the latest
if ($LatestFile -ne $CurrentItem) {

    # Download file
    (New-Object System.Net.WebClient).DownloadFile($DownloadURL, "$DownloadFolder$LatestFile")

    # Copy the items and move them to the New Setups folder
    #Rename-Item -Path "\\qrbak07\IT-Installs\New Setups\$LatestFile" -NewName "AdobeDCLatest.msp" 
    Copy-Item -Path "$DownloadFolder\$LatestFile" -Destination "$DestinationFolder\AdobeDCLatest.msp" -Force
    Copy-Item -Path "$DownloadFolder\$LatestFile" -Destination "$DestinationFolder\AdobeDCLatest.msp" -Force

    # Delete the older Adobe Reader MSP file so this folder doesnt grow
    Remove-Item -Path "$DownloadFolder\$CurrentItem" -Force
}
else {
    Write-Host "No new update to download"
}