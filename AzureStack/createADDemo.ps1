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
