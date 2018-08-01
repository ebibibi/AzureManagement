Add-AzureAccount
Get-AzureSubscription -SubscriptionName "JBS-ITS-DEV" | Select-AzureSubscription
Stop-AzureVM -ServiceName ebsjsc -Name ebsjdc01 -Force
Stop-AzureVM -ServiceName ebsjsc -Name ebsjsql01 -Force
Stop-AzureVM -ServiceName ebsjsc -Name ebsjscom2012r2 -Force
