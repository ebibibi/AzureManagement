Login-AzureRmAccount

$randomNumber = Get-random 100
$subscriptionName = "Microsoft Azure Sponsor PLAN"
$deploymentName = "S2DDemo"
$resourceGroupName = "mebisuda-S2DDemo"
$location = "Japan East"

#deploy parameters for new AD forest
$adminUsername = "mebisuda"
$adminPassword = Read-Host -AsSecureString -Prompt "password"
$domainName = "s2d.test"
$dnsPrefix = ("mebisudas2ddemoadvm")

#deploy parameters for member servers
$existingVNETName = "adVNET"
$existingSubnetName = "adSubnet"
$dnsLabelPrefix = "mebis2dnode"
$vmSize = "Standard_D2"
$ouPath = 'CN=Computers;DC=s2d;DC=test'


Get-AzureRmSubscription -SubscriptionName $subscriptionName | Select-AzureRmSubscription

# create resource group
New-AzureRmResourceGroup -Name $resourceGroupName -Location $location

# create new ad forest(adVM)
# https://azure.microsoft.com/ja-jp/resources/templates/active-directory-new-domain/
New-AzureRmResourceGroupDeployment -Name $deploymentName -ResourceGroupName $resourceGroupName -TemplateUri https://raw.githubusercontent.com/azure/azure-quickstart-templates/master/active-directory-new-domain/azuredeploy.json `
-adminUsername $adminUsername -adminPassword $adminPassword -domainName $domainName -dnsPrefix $dnsPrefix 

# add new server to the new ad domain
# https://azure.microsoft.com/ja-jp/resources/templates/201-vm-domain-join/
New-AzureRmResourceGroupDeployment -Name $deploymentName -ResourceGroupName $resourceGroupName -TemplateUri https://raw.githubusercontent.com/azure/azure-quickstart-templates/master/201-vm-domain-join/azuredeploy.json `
-existingVNETName $existingVNETName -existingSubnetName $existingSubnetName -dnsLabelPrefix ($dnsLabelPrefix+"1") -vmSize $vmSize -domainToJoin $domainName -domainUsername $adminUserName -domainPassword $adminPassword -ouPath $ouPath -vmAdminUsername $adminUsername -vmAdminPassword $adminPassword

New-AzureRmResourceGroupDeployment -Name $deploymentName -ResourceGroupName $resourceGroupName -TemplateUri https://raw.githubusercontent.com/azure/azure-quickstart-templates/master/201-vm-domain-join/azuredeploy.json `
-existingVNETName $existingVNETName -existingSubnetName $existingSubnetName -dnsLabelPrefix ($dnsLabelPrefix+"2") -vmSize $vmSize -domainToJoin $domainName -domainUsername $adminUserName -domainPassword $adminPassword -ouPath $ouPath -vmAdminUsername $adminUsername -vmAdminPassword $adminPassword

New-AzureRmResourceGroupDeployment -Name $deploymentName -ResourceGroupName $resourceGroupName -TemplateUri https://raw.githubusercontent.com/azure/azure-quickstart-templates/master/201-vm-domain-join/azuredeploy.json `
-existingVNETName $existingVNETName -existingSubnetName $existingSubnetName -dnsLabelPrefix ($dnsLabelPrefix+"3") -vmSize $vmSize -domainToJoin $domainName -domainUsername $adminUserName -domainPassword $adminPassword -ouPath $ouPath -vmAdminUsername $adminUsername -vmAdminPassword $adminPassword
