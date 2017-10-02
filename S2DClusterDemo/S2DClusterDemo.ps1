# スクリプトの前半はAzureの操作ができる任意の場所で実行してください。
# Azure PowerShellがインストールされている必要があります。
# コマンドレットが足りない場合、Install-Module AzureRMおよびUpdate-Moduleでアップデートしてください。
# Install-Module AzureRM
# Update-Module AzureRM

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
#$nodes = (($prefix + "node1"))
$nodes = (($prefix + "node1"), ($prefix + "node2"), ($prefix + "node3"), ($prefix + "node4"))
$existingVNETName = "adVNET"
$existingSubnetName = "adSubnet"
$vmSize = "Standard_D2"
$additionalDataDiskSizeGB = 1000


Get-AzureRmSubscription -SubscriptionName $subscriptionName | Select-AzureRmSubscription

# create resource group
New-AzureRmResourceGroup -Name $resourceGroupName -Location $location

# create storage account for witnesss
New-AzureRmStorageAccount -ResourceGroupName $resourceGroupName -Name $witnessSAName -SkuName Standard_LRS -Location $location -Kind Storage

# create new ad forest(adVM)
# https://github.com/ebibibi/AzureManagement/tree/master/newADForest
New-AzureRmResourceGroupDeployment -Name ($deploymentName + "DC") -ResourceGroupName $resourceGroupName -TemplateUri https://raw.githubusercontent.com/ebibibi/AzureManagement/master/newADForest/azuredeploy.json `
-adminUsername $adminUsername -adminPassword $adminPassword -domainName $domainName -dnsPrefix ($Prefix + "advm") -DeploymentDebugLogLevel All

# add new server to the new ad domain
# https://github.com/ebibibi/AzureManagement/tree/master/newDomainJoinedVM
foreach($node in $nodes) {
    New-AzureRmResourceGroupDeployment -Name $node -ResourceGroupName $resourceGroupName -TemplateUri https://raw.githubusercontent.com/ebibibi/AzureManagement/master/newDomainJoinedVM/azuredeploy.json `
    -existingVNETName $existingVNETName -existingSubnetName $existingSubnetName -dnsLabelPrefix $node -vmSize $vmSize -domainToJoin $domainName -domainUsername $adminUserName -domainPassword $adminPassword -vmAdminUsername $adminUsername -vmAdminPassword $adminPassword -DeploymentDebugLogLevel All

    # Adding one more Data Disk
    $dataDiskName = ($node + "disk2.vhd")
    $dataDiskUri = ("https://" + $node + "SA.blob.core.windows.net/vhds/" + $dataDiskName)
    $vm = Get-AzureRmVM -ResourceGroupName $resourceGroupName -Name $node
    $vm = Add-AzureRmVMDataDisk -VM $vm -Name $dataDiskName -CreateOption Empty -VhdUri $dataDiskUri -DiskSizeInGB $additionalDataDiskSizeGB -Lun 1
    Update-AzureRmVM -ResourceGroupName $resourceGroupName -VM $vm
}


# ここまで-----------------------------------------------------------------------



# 以下は展開されたクラスタノードとなるサーバー(例:node1)にRDPで入ってからその中で実行してください。-------------------------------

#nodes
$prefix = "ebis2d1"
$nodes = (($prefix + "node1"), ($prefix + "node2"), ($prefix + "node3"), ($prefix + "node4"))

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