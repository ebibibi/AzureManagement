cd d:\tools
[System.IO.Path]::GetTempPath() | Tee-Object  -Variable installerPath
$installer = ($installerPath + "AzureStack.Sql.1.1.18.0.exe")
Invoke-WebRequest -Uri https://aka.ms/azurestacksqlrp1802 -OutFile $installer

Start-Process "$installer"
