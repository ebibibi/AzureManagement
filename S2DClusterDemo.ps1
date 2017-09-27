Login-AzureRmAccount

$randomNumber = Get-random 100
$subscriptionName = "Microsoft Azure Sponsor PLAN"
$deploymentName = "S2DDemo"
$resourceGroupName = "mebisuda-S2DDemo"
$location = "Japan East"

$adminUsername = "mebisuda"
$domainName = "s2d.test"
$dnsPrefix = ("mebisudas2ddemo" + $randomNumber)

Get-AzureRmSubscription -SubscriptionName $subscriptionName | Select-AzureRmSubscription

# create resource group
New-AzureRmResourceGroup -Name $resourceGroupName -Location $location

# create new ad forest
# https://azure.microsoft.com/ja-jp/resources/templates/active-directory-new-domain/
New-AzureRmResourceGroupDeployment -DeploymentDebugLogLevel All -Name $deploymentName -ResourceGroupName $resourceGroupName -TemplateUri https://raw.githubusercontent.com/azure/azure-quickstart-templates/master/active-directory-new-domain/azuredeploy.json `
-adminUsername $adminUsername -domainName $domainName -dnsPrefix $dnsPrefix 



