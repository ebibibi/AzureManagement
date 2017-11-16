#Prepare--------------
# Specify Azure Active Directory tenant name
$TenantName = "xxxxxxx.onmicrosoft.com"

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
$ArmEndpointforAdmin = "https://adminmanagement.local.azurestack.external"
$ArmEndpointforUser = "https://management.local.azurestack.external"


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
#Create Storage Account on Azure 
#----------------------------------
Login-AzureRmAccount -EnvironmentName "AzureCloud"           

#Select Azure Subscription
Select-AzureRmSubscription -SubscriptionName "PublicAzure"

#Create Resource Group
New-AzureRmResourceGroup -Name PublicAzureRG -Location "japan east"

#Create Storage Account
New-AzureRmResourceGroupDeployment -Name publicazurestorage -ResourceGroupName PublicAzureRG `
  -TemplateFile D:\work\AzureStack-QuickStart-Templates-master\AzureStack-QuickStart-Templates-master\101-create-storage-account\azuredeploy.json -storageAccountType Standard_LRS

#----------------------------------
#Check your portal 
#----------------------------------

#----------------------------------
#Create Storage Account on Azure Stack
#----------------------------------
Login-AzureRmAccount `
  -EnvironmentName "AzureStackUser" `
  -TenantId $TenantIDforUser


#Select Azure Subscription
Select-AzureRmSubscription -SubscriptionName "AzureStack"

#Create Resource Group
New-AzureRmResourceGroup -Name AzureStackRG -Location "local"

#Create Storage Account
New-AzureRmResourceGroupDeployment -Name ExampleDeployment -ResourceGroupName AzureStackRG `
  -TemplateFile D:\work\AzureStack-QuickStart-Templates-master\AzureStack-QuickStart-Templates-master\101-create-storage-account\azuredeploy.json -storageAccountType Standard_LRS

#--------------------------------------------------------------------
#Create a AD domain controller server non-HA with PowerShell DSC Extension
#--------------------------------------------------------------------

#Resource group name. Please make sure the resource group does not exist 
$resourceGroupName = "adResourceGroup"
$deploymentName = "adDeployment"
$location = "Local" 
New-AzurermResourceGroup -Name $resourceGroupName -Location $location 

#Start new Deployment
New-AzurermResourceGroupDeployment -Name $deploymentName -ResourceGroupName $resourceGroupName `
    -TemplateParameterFile D:\work\AzureStack-QuickStart-Templates-master\AzureStack-QuickStart-Templates-master\ad-non-ha\azuredeploy.parameters.json -TemplateFile D:\work\AzureStack-QuickStart-Templates-master\AzureStack-QuickStart-Templates-master\ad-non-ha\azuredeploy.json
