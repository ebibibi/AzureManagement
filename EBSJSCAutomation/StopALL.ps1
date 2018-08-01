Add-AzureAccount
Get-AzureSubscription -SubscriptionName "JBS-ITS-DEV" | Select-AzureSubscription

Get-AzureVM -ServiceName EBSJSC | Stop-AzureVM -Force


