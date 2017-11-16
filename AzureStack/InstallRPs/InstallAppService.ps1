# https://docs.microsoft.com/en-us/azure/azure-stack/azure-stack-app-service-before-you-get-started

# download Installer and Hepler scripts
$workPath = "D:\appserviceInstaller\"
if (Test-Path $workPath)
{
    Remove-Item $workPath -Force -Recurse

}
mkdir $workPath

$helperScripts = ($workPath + "AppServiceHelperScripts.zip")
Invoke-WebRequest -Uri https://aka.ms/appsvconmashelpers -OutFile $helperScripts

$appserviceInstaller = ($workPath + "AppService.exe")
Invoke-WebRequest -Uri https://aka.ms/appsvconmasinstaller -OutFile $appserviceInstaller

#unzip
Add-Type -AssemblyName System.IO.Compression.FileSystem
function Unzip
{
    param([string]$zipfile, [string]$outpath)

    [System.IO.Compression.ZipFile]::ExtractToDirectory($zipfile, $outpath)
}

Unzip $helperScripts $workPath


