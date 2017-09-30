Login-AzureRmAccount
$prefix = "ebis2d1"

$subscriptionName = "Microsoft Azure Sponsor PLAN"
$deploymentName = "S2DDemo"
$resourceGroupName = ($prefix + "-Demo")
$location = "Japan East"

#witness storage account
$witnessSAName = ($prefix +"witness")

#deploy parameters for new AD forest
$adminUsername = "mebisuda"
$adminPassword = Read-Host -AsSecureString -Prompt "password"
$domainName = "s2d.test"

#deploy parameters for member servers
$existingVNETName = "adVNET"
$existingSubnetName = "adSubnet"
$vmSize = "Standard_D2"


Get-AzureRmSubscription -SubscriptionName $subscriptionName | Select-AzureRmSubscription

# create resource group
New-AzureRmResourceGroup -Name $resourceGroupName -Location $location

# create storage account for witnesss
New-AzureRmStorageAccount -ResourceGroupName $resourceGroupName -Name $witnessSAName -SkuName Standard_LRS -Location $location -Kind Storage

# create new ad forest(adVM)
# https://azure.microsoft.com/ja-jp/resources/templates/active-directory-new-domain/
New-AzureRmResourceGroupDeployment -Name ($deploymentName + "DC") -ResourceGroupName $resourceGroupName -TemplateUri https://raw.githubusercontent.com/azure/azure-quickstart-templates/master/active-directory-new-domain/azuredeploy.json `
-adminUsername $adminUsername -adminPassword $adminPassword -domainName $domainName -dnsPrefix ($Prefix + "advm") 

# add new server to the new ad domain
# https://azure.microsoft.com/ja-jp/resources/templates/201-vm-domain-join/
New-AzureRmResourceGroupDeployment -Name ($deploymentName+"node1") -ResourceGroupName $resourceGroupName -TemplateUri https://raw.githubusercontent.com/azure/azure-quickstart-templates/master/201-vm-domain-join/azuredeploy.json `
-existingVNETName $existingVNETName -existingSubnetName $existingSubnetName -dnsLabelPrefix ($prefix+"node1") -vmSize $vmSize -domainToJoin $domainName -domainUsername $adminUserName -domainPassword $adminPassword -vmAdminUsername $adminUsername -vmAdminPassword $adminPassword

New-AzureRmResourceGroupDeployment -Name ($deploymentName+"node2") -ResourceGroupName $resourceGroupName -TemplateUri https://raw.githubusercontent.com/azure/azure-quickstart-templates/master/201-vm-domain-join/azuredeploy.json `
-existingVNETName $existingVNETName -existingSubnetName $existingSubnetName -dnsLabelPrefix ($prefix+"node2") -vmSize $vmSize -domainToJoin $domainName -domainUsername $adminUserName -domainPassword $adminPassword -vmAdminUsername $adminUsername -vmAdminPassword $adminPassword

New-AzureRmResourceGroupDeployment -Name ($deploymentName+"node3") -ResourceGroupName $resourceGroupName -TemplateUri https://raw.githubusercontent.com/azure/azure-quickstart-templates/master/201-vm-domain-join/azuredeploy.json `
-existingVNETName $existingVNETName -existingSubnetName $existingSubnetName -dnsLabelPrefix ($prefix+"node3") -vmSize $vmSize -domainToJoin $domainName -domainUsername $adminUserName -domainPassword $adminPassword -vmAdminUsername $adminUsername -vmAdminPassword $adminPassword

New-AzureRmResourceGroupDeployment -Name ($deploymentName+"node4") -ResourceGroupName $resourceGroupName -TemplateUri https://raw.githubusercontent.com/azure/azure-quickstart-templates/master/201-vm-domain-join/azuredeploy.json `
-existingVNETName $existingVNETName -existingSubnetName $existingSubnetName -dnsLabelPrefix ($prefix+"node4") -vmSize $vmSize -domainToJoin $domainName -domainUsername $adminUserName -domainPassword $adminPassword -vmAdminUsername $adminUsername -vmAdminPassword $adminPassword

#--------------------------------------------------------------------------




#enable-psremoting
Enable-PSRemoting
Set-Item WSMan:\localhost\Client\TrustedHosts "*"

#nodes
$prefix = "ebis2d1"
$nodes = (($prefix + "node1"), ($prefix + "node2"), ($prefix + "node3"))

#confifure nodes
Invoke-Command -ComputerName $nodes -ScriptBlock {
    #disable firewall
    #Get-NetFirewallProfile | Set-NetFirewallProfile -Enabled false

    #add failover cluster role
    Add-WindowsFeature Failover-Clustering -IncludeManagementTools

    #add fileserver role
    Install-WindowsFeature FS-FileServer
}


# create failover cluster
# We must use static IP for Cluster resource
New-Cluster -Name S2DCluster -Node $nodes –StaticAddress 10.0.0.100

# add cloud monitoring
$witnessSAName = ($prefix +"witness")
Set-ClusterQuorum -CloudWitness -AccountName $witnessSAName -AccessKey (Read-Host -Prompt "AccessKey for witness SA.")

#clean up all disks(option)
Invoke-Command (Get-Cluster -Name $nodes[0]| Get-ClusterNode) {
    Update-StorageProviderCache
    Get-StoragePool | Where-Object IsPrimordial -eq $false | Set-StoragePool -IsReadOnly:$false -ErrorAction SilentlyContinue
    Get-StoragePool | Where-Object IsPrimordial -eq $false | Get-VirtualDisk | Remove-VirtualDisk -Confirm:$false -ErrorAction SilentlyContinue
    Get-StoragePool | Where-Object IsPrimordial -eq $false | Remove-StoragePool -Confirm:$false -ErrorAction SilentlyContinue
    Get-PhysicalDisk | Reset-PhysicalDisk -ErrorAction SilentlyContinue
    Get-Disk | Where-Object Number -ne $null | Where-Object IsBoot -ne $true | Where-Object IsSystem -ne $true | Where-Object PartitionStyle -ne RAW | ForEach-Object {
    $_ | Set-Disk -isoffline:$false
    $_ | Set-Disk -isreadonly:$false
    $_ | Clear-Disk -RemoveData -RemoveOEM -Confirm:$false
    $_ | Set-Disk -isreadonly:$true
    $_ | Set-Disk -isoffline:$true
    }
    
    Get-Disk |Where-Object Number -ne $null |Where-Object IsBoot -ne $true |Where-Object IsSystem -ne $true |Where-Object PartitionStyle -eq RAW | Group-Object -NoElement -Property FriendlyName
    
    } | Sort-Object -Property PsComputerName,Count


# change fault domain
#New-ClusterFaultDomain –Type Site –Name “Tokyo” –Location “TokyoDC”
#New-ClusterFaultDomain –Type Rack –Name “Rack 1” –Location “Room 210, Aisle A”
#Set-ClusterFaultDomain –Name $nodes[0] –Parent “Rack 1” –Location “U1”
#Set-ClusterFaultDomain –Name $nodes[1] –Parent “Rack 1” –Location “U2”
#Set-ClusterFaultDomain –Name $nodes[2] –Parent “Rack 1” –Location “U3”
#Set-ClusterFaultDomain –Name “Rack 1” –Parent “Tokyo”


# enable S2D (automatically created cluster pool)
Enable-ClusterS2D

# create new volume (this operation should be done by GUI but It couldn't now)
Get-StoragePool S2D*| Get-ResiliencySetting
Get-StorageTier
Get-StorageTier | Set-StorageTier -FaultDomainAwareness PhysicalDisk

New-Volume -StoragePoolFriendlyName S2D* -FriendlyName VDisk01 -FileSystem CSVFS_REFS -Size 100GB -ResiliencySettingName Mirror -PhysicalDiskRedundancy 1
New-Volume -StoragePoolFriendlyName S2D* -FriendlyName VDisk02 -FileSystem CSVFS_REFS -Size 100GB -ResiliencySettingName Parity -PhysicalDiskRedundancy 1
#New-Volume -StoragePoolFriendlyName S2D* -FriendlyName VDisk03 -FileSystem CSVFS_REFS -Size 100GB -ResiliencySettingName Mirror -PhysicalDiskRedundancy 2


# create SOFS
Add-ClusterScaleOutFileServerRole -Name S2D-SOFS
New-Item -Path C:\ClusterStorage\Volume1\Data -ItemType Directory
New-SmbShare -Name Share1 -Path C:\ClusterStorage\Volume1\Data -FullAccess Everyone

# add cluster node
Add-ClusterNode -Name $nodes[4]
#Set-ClusterFaultDomain –Name $nodes[4] –Parent “Rack 1” –Location “U3”
#Get-StoragePool S2D* | Optimize-StoragePool

# remove cluster node
Remove-ClusterNode -Name $nodes[4] -CleanupDisks


#Change to Japanese GUI(option)
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