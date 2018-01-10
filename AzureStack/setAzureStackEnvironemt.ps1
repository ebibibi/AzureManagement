#Prepare--------------
# Specify Azure Active Directory tenant name
#$TenantName = "jbsazsta.onmicrosoft.com"
$TenantName = "jbsbpos.apac.microsoftonline.com"


# Navigate to the downloaded folder and import the **Connect** PowerShell module
Set-ExecutionPolicy Unrestricted -Force

# Download Azure Stack tools from GitHub and import the connect module
cd \

invoke-webrequest `
  https://github.com/Azure/AzureStack-Tools/archive/master.zip `
  -OutFile master.zip

expand-archive master.zip `
  -DestinationPath . `
  -Force

cd AzureStack-Tools-master

Import-Module `
  .\Connect\AzureStack.Connect.psm1

# For Azure Stack development kit, this value is set to https://adminmanagement.local.azurestack.external. To get this value for Azure Stack integrated systems, contact your service provider.
#$ArmEndpointforAdmin = "https://adminmanagement.local.azurestack.external"
#$ArmEndpointforUser = "https://management.local.azurestack.external"
$ArmEndpointforAdmin = "https://adminmanagement.tokyo.mas.jbs.com"
$ArmEndpointforUser = "https://management.tokyo.mas.jbs.com"


# For Azure Stack development kit, this value is set to https://graph.windows.net/. To get this value for Azure Stack integrated systems, contact your service provider.
$GraphAudience = "https://graph.windows.net/"

# Register an AzureRM environment that targets your Azure Stack instance
Add-AzureRMEnvironment `
  -Name "AzureStackUser" `
  -ArmEndpoint $ArmEndpointforUser

Add-AzureRMEnvironment `
  -Name "AzureStackAdmin" `
  -ArmEndpoint $ArmEndpointforAdmin

Set-AzureRmEnvironment `
  -Name "AzureStackUser" `
  -GraphAudience $GraphAudience

Set-AzureRmEnvironment `
  -Name "AzureStackAdmin" `
  -GraphAudience $GraphAudience


$TenantIDforUser = Get-AzsDirectoryTenantId `
  -AADTenantName $TenantName `
  -EnvironmentName AzureStackUser

$TenantIDforAdmin = Get-AzsDirectoryTenantId `
  -AADTenantName $TenantName `
  -EnvironmentName AzureStackAdmin

#Prepare--------------

#----------------------------------
#Check Environments
#----------------------------------
Get-AzureRmEnvironment | ft name, ResourceManagerUrl
Get-AzureRmEnvironment -Name AzureCloud
Get-AzureRmEnvironment -Name AzureStackAdmin
Get-AzureRmEnvironment -Name AzureStackUser


#----------------------------------
#Login to Azure Environments
#----------------------------------
#Login-AzureRmAccount -EnvironmentName "AzureCloud"
#Login-AzureRmAccount -EnvironmentName "AzureStackUser"
#Login-AzureRmAccount -EnvironmentName "AzureStackAdmin"