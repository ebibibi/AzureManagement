param
(
    [string] $name,
    [string] $vmSize,
    [string] $vmVisualStudioVersion,
    [string] $password
)
#import-module
Import-Module AzureRm.Profile


#log
$log = "c:\log\Create-DevVMwithVisualStudio.log"

Function log
{
    param([string]$message)
    Write-Output ([string](Get-Date) + ":" + $message) >> $log
}


#サイズの余分な説明を削除する
$vmSize = ($vmSize.Split('(')[0]).TrimEnd(" ")

#パラメータの確認
log $name
log $vmSize
log $vmVisualStudioVersion
log $password


#Credential, Subscription
$userName = "ebsjsc-automation@isdeptazurejokerjbs.onmicrosoft.com"
#$password = "password"
$securePassword = $password | ConvertTo-SecureString -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential -ArgumentList $userName, $securePassword 
Login-AzureRmAccount -Credential $cred -SubscriptionName "JBS-ITS-DEV"
log "Login-AzureRmAccount done"

#Deploy
$resourceGroupName = ($name + "resourcegroup")
$deployLocation = 'Japan East'
$storageName = ($name + "storage")
$vmName = ($name + "vm")
$vmAdminUserName = "devvmadmin"
$vmAdminPassword = $password | ConvertTo-SecureString -AsPlainText -Force
#$vmSize = 'Basic_A1'
#$vmVisualStudioVersion = "VS-2013-Comm-VSU5-AzureSDK-2.8-WS2012R2"
$vmIPPublicDnsName = ($name + "dnsname").ToLower()

New-AzureRmResourceGroup -Name $resourceGroupName -Location $deployLocation -Force
New-AzureRmResourceGroupDeployment -TemplateUri https://raw.githubusercontent.com/azure/azure-quickstart-templates/master/visual-studio-dev-vm/azuredeploy.json `
    -Name $name `
    -ResourceGroupName $resourceGroupName `
    -storageType Standard_LRS `
    -deployLocation $deployLocation `
    -vmName $vmName `
    -vmAdminUserName $vmAdminUserName `
    -vmAdminPassword $vmAdminPassword `
    -vmSize $vmSize `
    -vmVisualStudioVersion $vmVisualStudioVersion `
    -vmIPPublicDnsName $vmIPPublicDnsName

# .\Create-DevVMwithVisualStudio.ps1 -name aaaaa -vmSize Basic_A1 -vmVisualStudioVersion VS-2013-Comm-VSU5-AzureSDK-2.8-WS2012R2
#VS-2015-Pro-VSU1-AzureSDK-2.8-W10T-1511-N-x64
#VS-2015-Pro-AzureSDK-2.8-Cordova-Win8.1-N-x64
#VS-2015-Ent-VSU1-AzureSDK-2.8-WS2012R2
#VS-2015-Ent-VSU1-AzureSDK-2.8-W10T-1511-N-x64
#VS-2015-Comm-VSU1-AzureSDK-2.8-WS2012R2
#VS-2015-Comm-VSU1-AzureSDK-2.8-W10T-N-x64
#VS-2015-Comm-AzureSDK-2.8-Cordova-Win8.1-N-x64
#VS-2013-Ultimate-VSU5-AzureSDK-2.8-WS2012R2
#VS-2013-Prem-VSU5-AzureSDK-2.8-WS2012R2
#VS-2013-Comm-VSU5-Cordova-CTP3.2-AzureSDK-2.8-WS2012R2
#VS-2013-Comm-VSU5-AzureSDK-2.8-WS2012R2