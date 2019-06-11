#
# Script to import multiple properly formatted password files into CyberArk
# Requirements: PasswordUpload.exe configuration file must be named config.ini
#

Clear-Host
Write-Host "CyberArk Bulk Password Import Script`r`nCopyright 2018`r`n"

# Remove any stale 'passwords.csv files that will interfere with generating file list...
if ((Test-Path -path passwords.csv) -eq $true) {
    Remove-Item passwords.csv
}

$LogFile = "Password_Import_Log-$(Get-Date -f yyyy-MM-dd)_$(Get-Date -f HHmmss).txt"

# Get a list of the CSV files in the current directory...
$Files = Get-Item *.csv

if ($Files -eq $null) {
    Write-Host "No password CSV files found...`r`nExiting."
    exit
} else {
    Write-Host "Found the following password CSV files..."
    
    foreach ($file in $Files) {
        Write-Host $file
    }
    
    Write-Host "`r`nImporting files..."
    
    foreach ($file in $Files) {
        Write-Host "Importing $file"
        Copy-Item $file passwords.csv -force
        .\PasswordUpload.exe config.ini | Out-File -FilePath $LogFile -append
        Write-Host "Moving $file to ARCHIVE directory"
        Move-Item $file ./ARCHIVE/ -force
    }
    
    
    Write-Host "`r`nComplete!   See $LogFile for status of imports.`r`nCleaning up..."
    
    #Remove the unneeded passwords.csv file...
    Remove-Item passwords.csv

    Write-Host "Exiting."
}
