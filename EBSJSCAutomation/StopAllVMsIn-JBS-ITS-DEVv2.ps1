workflow StopAllVMsIn-JBS-ITS-DEVv2
{
    $azureCredential = Get-AutomationPSCredential -Name "Default Automation Credential"

 	# Connect to Azure
	Login-AzureRmAccount -Credential $azureCredential | Write-Verbose 

	# Select the Azure subscription 
	$SubscriptionName = 'JBS-ITS-DEV'
	Select-AzureSubscription -SubscriptionName $SubscriptionName

    Write-Output "-------------------------------------------------------------------------"
    Write-Output "Shutdown v2 VMs"
    Get-AzureRmVM | Stop-AzureRmVM -Force -Verbose
    
    Write-Output "-------------------------------------------------------------------------"	
	
}