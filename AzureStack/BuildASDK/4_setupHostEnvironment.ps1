#install chrome
$LocalTempDir = $env:TEMP
$ChromeInstaller = "ChromeInstaller.exe"
(new-object    System.Net.WebClient).DownloadFile('http://dl.google.com/chrome/install/375.126/chrome_installer.exe', "$LocalTempDir\$ChromeInstaller")
& "$LocalTempDir\$ChromeInstaller" /silent /install
$Process2Monitor =  "ChromeInstaller"
Do { 
    $ProcessesFound = Get-Process | ?{$Process2Monitor -contains $_.Name} | Select-Object -ExpandProperty Name
    If ($ProcessesFound) {
        "Still running: $($ProcessesFound -join ', ')" | Write-Host
        Start-Sleep -Seconds 2 
    } else {
        rm "$LocalTempDir\$ChromeInstaller" -ErrorAction SilentlyContinue -Verbose 
    } 
} Until (!$ProcessesFound)

#disable IE ESC
function Disable-IEESC
{
$AdminKey = “HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A7-37EF-4b3f-8CFC-4F3A74704073}”
$UserKey = “HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A8-37EF-4b3f-8CFC-4F3A74704073}”
Set-ItemProperty -Path $AdminKey -Name “IsInstalled” -Value 0
Set-ItemProperty -Path $UserKey -Name “IsInstalled” -Value 0
Stop-Process -Name Explorer
}
Disable-IEESC


#install git
$LocalTempDir = $env:TEMP
$GitInstaller = "Git-2.17.0-64-bit.exe"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
(new-object    System.Net.WebClient).DownloadFile('https://github.com/git-for-windows/git/releases/download/v2.17.0.windows.1/Git-2.17.0-64-bit.exe', "$LocalTempDir\$GitInstaller")
& "$LocalTempDir\$GitInstaller"  /SILENT /COMPONENTS="icons,ext\reg\shellhere,assoc,assoc_sh"
$Process2Monitor =  "Git-2.16.2-64-bit.exe"
Do { 
    $ProcessesFound = Get-Process | ?{$Process2Monitor -contains $_.Name} | Select-Object -ExpandProperty Name
    If ($ProcessesFound) {
        "Still running: $($ProcessesFound -join ', ')" | Write-Host
        Start-Sleep -Seconds 2 
    } else {
        rm "$LocalTempDir\$GitInstaller" -ErrorAction SilentlyContinue -Verbose 
    } 
} Until (!$ProcessesFound)







#Install VSCode
$LocalTempDir = $env:TEMP
$VSCodeInstaller = "VSCodeSetup-x64.exe"
(new-object    System.Net.WebClient).DownloadFile('https://go.microsoft.com/fwlink/?Linkid=852157', "$LocalTempDir\$VSCodeInstaller")
& "$LocalTempDir\$VSCodeInstaller" /VERYSILENT /MEGGETASKS=!runcode
$Process2Monitor =  "VSCodeSetup-x64.exe"
Do { 
    $ProcessesFound = Get-Process | ?{$Process2Monitor -contains $_.Name} | Select-Object -ExpandProperty Name
    If ($ProcessesFound) {
        "Still running: $($ProcessesFound -join ', ')" | Write-Host
        Start-Sleep -Seconds 2 
    } else {
        rm "$LocalTempDir\$VSCodeInstaller" -ErrorAction SilentlyContinue -Verbose 
    } 
} Until (!$ProcessesFound)


#install TortoiseGit
$LocalTempDir = $env:TEMP
$TortoiseGitInstaller = "TortoiseGit-2.6.0.0-64bit.msi"
(new-object    System.Net.WebClient).DownloadFile('https://download.tortoisegit.org/tgit/2.6.0.0/TortoiseGit-2.6.0.0-64bit.msi', "$LocalTempDir\$TortoiseGitInstaller")
& msiexec.exe /i "$LocalTempDir\$TortoiseGitInstaller" /passive
$Process2Monitor =  "msiexec.exe"
Do { 
    $ProcessesFound = Get-Process | ?{$Process2Monitor -contains $_.Name} | Select-Object -ExpandProperty Name
    If ($ProcessesFound) {
        "Still running: $($ProcessesFound -join ', ')" | Write-Host
        Start-Sleep -Seconds 2 
    } else {
        rm "$LocalTempDir\$TortoiseGitInstaller" -ErrorAction SilentlyContinue -Verbose 
    } 
} Until (!$ProcessesFound)


#open directory
cd D:\ReBuildASDK\AzureManagement\AzureStack
Invoke-Item .