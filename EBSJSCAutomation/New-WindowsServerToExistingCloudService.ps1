workflow New-WindowsServerToExistingCloudService
{
	Param(
		[parameter(Mandatory=$true)]
        [String] $VMName, 
        
        [parameter(Mandatory=$false)]
        [String] $VMAdminUsername = "mebisuda", 

        [parameter(Mandatory=$false)]
        [String] $VMAdminPassword = "AzurenoP@ssw0rd",

		[parameter(Mandatory=$true)]
        [String] $AzureCredentialName,

        [parameter(Mandatory=$true)]
        [String] $AzureSubscriptionName,

        [parameter(Mandatory=$true)]
        [String] $CloudServiceName,

        [parameter(Mandatory=$true)]
        [String] $vNetName,
        
        [parameter(Mandatory=$true)]
        [String] $SubnetName
	)
    
        
    # Provision virtual machine
    Write-Verbose "Creating new VM instance from latest OS image"
    InlineScript 
    { 
        $image = Get-AzureVMImage | Where-Object {$_.Label -like "Windows Server 2012 R2 Datacenter*"} |
                    sort PublishedDate -Descending | select -First 1 -ExpandProperty ImageName
        $VMConfig = New-AzureVMConfig -Name $Using:vmName -InstanceSize "Medium" -ImageName $image 
        Add-AzureProvisioningConfig -VM $VMConfig -Windows -AdminUsername $Using:VMAdminUsername -Password $Using:VMAdminPassword |
                    Set-AzureSubnet -SubnetNames $Using:SubnetName |
                    Out-Null
       
        # Provision virtual machine
        $vmSettings = @{
            ServiceName = $Using:cloudServiceName
            VNetName = $Using:vNetName
            VMs = $VMConfig
            WaitForBoot = $false
        }
        
        # Create VM
        $newVMResult = New-AzureVM @vmSettings
        if($newVMResult -eq $null -or $newVMResult.OperationStatus -ne "Succeeded")
        {
            throw "Failed to create virtual machine for deployment. Returned status was [$($newVMResult.OperationStatus)]"
        }

        
    }
    
    Write-Verbose "Runbook finished."
    
    # End of runbook
}