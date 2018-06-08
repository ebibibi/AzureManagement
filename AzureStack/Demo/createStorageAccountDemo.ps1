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
