Add-AzureAccount
Get-AzureSubscription -SubscriptionName "JBS-ITS-DEV" | Select-AzureSubscription
Start-AzureVM -ServiceName ebsjsc -Name ebsjdc01 -Verbose
Start-AzureVM -ServiceName ebsjsc -Name ebsjsql01 -Verbose
Start-AzureVM -ServiceName ebsjsc -Name ebsjsccm01 -Verbose

