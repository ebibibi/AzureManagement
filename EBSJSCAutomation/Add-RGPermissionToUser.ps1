param
(
    [string] $user,
    [string] $resourcegroupName
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


#パラメータの確認
log $user
log $resourcegroup


#Credential, Subscription
$userName = "ebsjsc-automation@isdeptazurejokerjbs.onmicrosoft.com"
$password = "AzurenoP@ssw0rd1"
$securePassword = $password | ConvertTo-SecureString -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential -ArgumentList $userName, $securePassword 
Login-AzureRmAccount -Credential $cred -SubscriptionName "JBS-ITS-DEV"


#Deploy
#サブスクリプションの既定のディレクトリにあらかじめMicrosoftアカウントは追加しておかないといけない
New-AzureRmRoleAssignment -SignInName $user -ResourceGroupName $resourcegroupName -RoleDefinitionName "Reader"