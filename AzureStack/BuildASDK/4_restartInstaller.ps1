# some case, I have to manually enable hypervisor
bcdedit /set hypervisorlaunchtype auto

Set-Location C:\CloudDeployment\Setup
.\InstallAzureStackPOC.ps1 -Rerun -Vervose
