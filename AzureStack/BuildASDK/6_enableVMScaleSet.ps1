Set-PSRepository `
  -Name "PSGallery" `
  -InstallationPolicy Trusted

# Install the AzureRM.Bootstrapper module. Select Yes when prompted to install NuGet 
Install-Module `
  -Name AzureRm.BootStrapper

# Install and import the API Version Profile required by Azure Stack into the current PowerShell session.
Use-AzureRmProfile `
  -Profile 2017-03-09-profile -Force

Install-Module `
  -Name AzureStack `
  -RequiredVersion 1.2.11

Install-Module AzureRM.AzureStackAdmin

Import-Module "D:\Tools\AzureStack-Tools-master\Connect\AzureStack.Connect.psm1"
Import-Module "D:\Tools\AzureStack-Tools-master\ComputeAdmin\AzureStack.ComputeAdmin.psm1"


$Arm = "https://adminmanagement.local.azurestack.external"
$Location = "local"

Add-AzureRMEnvironment -Name AzureStackAdmin -ArmEndpoint $Arm
$AzsEnv = Get-AzureRmEnvironment AzureStackAdmin
$AzsEnvContext = Add-AzureRmAccount -Environment $AzsEnv

Select-AzureRmSubscription -SubscriptionName "Default Provider Subscription"

Add-AzsVMSSGalleryItem -Location $Location