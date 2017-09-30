Login-AzureRmAccount

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


Get-AzureRmSubscription -SubscriptionName $subscriptionName | Select-AzureRmSubscription

# create resource group
New-AzureRmResourceGroup -Name $resourceGroupName -Location $location

# create new ad forest(adVM)
# https://azure.microsoft.com/ja-jp/resources/templates/active-directory-new-domain/
New-AzureRmResourceGroupDeployment -Name ($deploymentName + "DC") -ResourceGroupName $resourceGroupName -TemplateUri https://raw.githubusercontent.com/azure/azure-quickstart-templates/master/active-directory-new-domain/azuredeploy.json `
-adminUsername $adminUsername -adminPassword $adminPassword -domainName $domainName -dnsPrefix $dnsPrefix 

# add new server to the new ad domain
# https://azure.microsoft.com/ja-jp/resources/templates/201-vm-domain-join/
New-AzureRmResourceGroupDeployment -Name ($deploymentName+"node1") -ResourceGroupName $resourceGroupName -TemplateUri https://raw.githubusercontent.com/azure/azure-quickstart-templates/master/201-vm-domain-join/azuredeploy.json `
-existingVNETName $existingVNETName -existingSubnetName $existingSubnetName -dnsLabelPrefix ($dnsLabelPrefix+"1") -vmSize $vmSize -domainToJoin $domainName -domainUsername $adminUserName -domainPassword $adminPassword -vmAdminUsername $adminUsername -vmAdminPassword $adminPassword

New-AzureRmResourceGroupDeployment -Name ($deploymentName+"node2") -ResourceGroupName $resourceGroupName -TemplateUri https://raw.githubusercontent.com/azure/azure-quickstart-templates/master/201-vm-domain-join/azuredeploy.json `
-existingVNETName $existingVNETName -existingSubnetName $existingSubnetName -dnsLabelPrefix ($dnsLabelPrefix+"2") -vmSize $vmSize -domainToJoin $domainName -domainUsername $adminUserName -domainPassword $adminPassword -vmAdminUsername $adminUsername -vmAdminPassword $adminPassword

New-AzureRmResourceGroupDeployment -Name ($deploymentName+"node3") -ResourceGroupName $resourceGroupName -TemplateUri https://raw.githubusercontent.com/azure/azure-quickstart-templates/master/201-vm-domain-join/azuredeploy.json `
-existingVNETName $existingVNETName -existingSubnetName $existingSubnetName -dnsLabelPrefix ($dnsLabelPrefix+"3") -vmSize $vmSize -domainToJoin $domainName -domainUsername $adminUserName -domainPassword $adminPassword -vmAdminUsername $adminUsername -vmAdminPassword $adminPassword

New-AzureRmResourceGroupDeployment -Name ($deploymentName+"node4") -ResourceGroupName $resourceGroupName -TemplateUri https://raw.githubusercontent.com/azure/azure-quickstart-templates/master/201-vm-domain-join/azuredeploy.json `
-existingVNETName $existingVNETName -existingSubnetName $existingSubnetName -dnsLabelPrefix ($dnsLabelPrefix+"4") -vmSize $vmSize -domainToJoin $domainName -domainUsername $adminUserName -domainPassword $adminPassword -vmAdminUsername $adminUsername -vmAdminPassword $adminPassword

#Change to Japanese GUI
$LpUrl = "http://fg.v4.download.windowsupdate.com/c/msdownload/update/software/updt/2016/09/"
$LpFile = "lp_9a666295ebc1052c4c5ffbfa18368dfddebcd69a.cab"
$LpTemp = "C:\LpTemp.cab"
Set-WinUserLanguageList -LanguageList ja-JP,en-US -Force
Start-BitsTransfer -Source $LpUrl$LpFile -Destination $LpTemp -Priority High
Add-WindowsPackage -PackagePath $LpTemp -Online
Set-WinDefaultInputMethodOverride -InputTip "0411:00000411"
Set-WinLanguageBarOption -UseLegacySwitchMode -UseLegacyLanguageBar
Remove-Item $LpTemp -Force
Restart-Computer

Set-WinUILanguageOverride -Language ja-JP
Set-WinCultureFromLanguageListOptOut -OptOut $False
Set-WinHomeLocation -GeoId 0x7A
Set-WinSystemLocale -SystemLocale ja-JP
Set-TimeZone -Id "Tokyo Standard Time"
Restart-Computer


#add failover cluster role
Enable-PSRemoting
Invoke-Command -ComputerName mebis2dnode1, mebis2dnode2, mebis2dnode3, mebis2dnode4 -Credential Get-Credential -ScriptBlock {Add-WindowsFeature Failover-Clustering}

