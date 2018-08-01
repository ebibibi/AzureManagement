workflow StopAllVMsIn-JBS-ITS-DEV
{
    $azureCredential = Get-AutomationPSCredential -Name "Default Automation Credential"

 	# Connect to Azure
    Add-AzureAccount -Credential $azureCredential | Write-Verbose

	# Select the Azure subscription 
	$SubscriptionName = 'JBS-ITS-DEV'
	Select-AzureSubscription -SubscriptionName $SubscriptionName

    Write-Output "-------------------------------------------------------------------------"
    Write-Output "Shutdown v1 VMs"
    Get-AzureVM | Stop-AzureVM -Force

    #Switch-AzureMode -Name AzureResourceManager
    #Write-Output "Shutdown v2 VMs"
    #Get-AzureVM | Stop-AzureVM -Force -Verbose
    
    Write-Output "-------------------------------------------------------------------------"

}