Add-AzureAccount
Get-AzureSubscription -SubscriptionName "JBS-ITS-DEV" | Select-AzureSubscription
Start-AzureVM -ServiceName ebsjsc -Name ebsjdc01
Start-AzureVM -ServiceName ebsjsc -Name ebsjsql02
Start-AzureVM -ServiceName ebsjsc -Name ebsjscsm2012r2
#Start-AzureVM -ServiceName ebsjsc -Name ebsjscsmp2012r2
Start-AzureVM -ServiceName ebsjsc -Name ebsjscsmnewp
Start-AzureVM -ServiceName ebsjsc -Name ebsjsql01
Start-AzureVM -ServiceName ebsjsc -Name ebsjsco2012r2
