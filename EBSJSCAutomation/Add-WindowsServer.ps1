workflow Add-WindowsServer
{
	Param
    (
        [parameter(Mandatory=$true)]
        [String] $VMName, 
        
        [parameter(Mandatory=$false)]
        [String] $VMAdminUsername = "mebisuda", 

        [parameter(Mandatory=$false)]
        [String] $VMAdminPassword = "AzurenoP@ssw0rd",

		[parameter(Mandatory=$false)]
        [String] $DomainAdminUsername = "ebsjsc\mebisuda", 

        [parameter(Mandatory=$false)]
        [String] $DomainAdminPassword = "AzurenoP@ssw0rd",

		[parameter(Mandatory=$false)]
        [String] $AzureCredentialName = "Use *Default Automation Credential* Asset",

        [parameter(Mandatory=$false)]
        [String] $AzureSubscriptionName = "Use *Default Azure Subscription* Variable Value",

        [parameter(Mandatory=$false)]
        [String] $CloudServiceName = "Use *Default Cloud Service Name* Variable Value",

        [parameter(Mandatory=$false)]
        [String] $vNetName = "Use *Default vNet Name* Variable Value",
        
        [parameter(Mandatory=$false)]
        [String] $SubnetName = "Use *Default Subnet Name* Variable Value",

		[parameter(Mandatory=$false)]
        [String] $DomainName = "ebsjsc.local"
    )
    
    # Verbose output by default
    $VerbosePreference = "Continue"
    Write-Verbose "Start."
    
	#region set parameters

    # Retrieve credential name from variable asset if not specified
    if($AzureCredentialName -eq "Use *Default Automation Credential* asset")
    {
        $azureCredential = Get-AutomationPSCredential -Name "Default Automation Credential"
        if($azureCredential -eq $null)
        {
            Write-Output "ERROR: No automation credential name was specified, and no credential asset with name 'Default Automation Credential' was found. Either specify a stored credential name or define the default using a credential asset"
            return
        }
    }
    else
    {
        $azureCredential = Get-AutomationPSCredential -Name $AzureCredentialName
        if($azureCredential -eq $null)
        {
            Write-Output "ERROR: Failed to get credential with name [$AzureCredentialName]"
            return
        }
    }
    
    # Connect to Azure using credential asset
    $addAccountResult = Add-AzureAccount -Credential $azureCredential

    # Retrieve subscription name from variable asset if not specified
    if($AzureSubscriptionName -eq "Use *Default Azure Subscription* Variable Value")
    {
        $AzureSubscriptionName = Get-AutomationVariable -Name "Default Azure Subscription"
        if($AzureSubscriptionName.length -eq 0)
        {
            Write-Output "ERROR: No subscription name was specified, and no variable asset with name 'Default Azure Subscription' was found. Either specify an Azure subscription name or define the default using a variable setting"
            return
        }
    }
    
    # Validate subscription
    InlineScript 
    {
        $subscription = Get-AzureSubscription -Name $Using:AzureSubscriptionName
        if($subscription -eq $null)
        {
            Write-Output "ERROR: No subscription found with name [$Using:AzureSubscriptionName] that is accessible to user [$($Using:azureCredential.UserName)]"
            return
        }
    }
    
	# Select the Azure subscription we will be working against
    $subscriptionResult = Select-AzureSubscription -Current $AzureSubscriptionName
    
    
    # Retrieve cloud service name from variable asset if not specified
    if($CloudServiceName -eq "Use *Default Cloud Service Name* Variable Value")
    {
        $CloudServiceName = Get-AutomationVariable -Name "Default Cloud Service Name"
        if($CloudServiceName.length -eq 0)
        {
            Write-Output "ERROR: No cloud service name was specified, and no variable asset with name 'Default Cloud Service Name' was found. Either specify an cloud service name or define the default using a variable setting"
            return
        }
    }
    
    # Get cloud service
    Write-Verbose "Get cloud service [$CloudServiceName] for deployment"
    $cloudServiceResult = Get-AzureService -ServiceName $CloudServiceName

    # Check result
    if($cloudServiceResult -eq $null -or $cloudServiceResult.OperationStatus -ne "Succeeded")
    {
        throw "Failed to get cloud service for adding server."
    }
    Write-Verbose "Got cloud service [$cloudServiceName]"

    # Get storage account for deployment based on cloud service name
    $storageAccountName = ($cloudServiceName + "st").ToLower()
    Write-Verbose "Getting storage account [$storageAccountName] for deployment"
    
    $storageAccountResult = Get-AzureStorageAccount -StorageAccountName $storageAccountName
    if($storageAccountResult -eq $null -or $storageAccountResult.OperationStatus -ne "Succeeded")
    {
        throw "Failed to get storage account for deployment"
    }
    Write-Verbose "Got storage account [$storageAccountName]"
    
    # Reference the new storage account to target deployment of virtual machines
    $subscriptionResult = Set-AzureSubscription -SubscriptionName $AzureSubscriptionName -CurrentStorageAccount $storageAccountName


    # Retrieve vNet name from variable asset if not specified
    if($vNetName -eq "Use *Default vNet Name* Variable Value")
    {
        $vNetName = Get-AutomationVariable -Name "Default vNet Name"
        if($vNetName.length -eq 0)
        {
            Write-Output "ERROR: No vNet name was specified, and no variable asset with name 'Default vNetName' was found. Either specify an vNet name or define the default using a variable setting"
            return
        }
    }
    
    # Validate vNet
    Write-Verbose "Getting vNet for deployment"
    $vNetResult = Get-AzureVNetSite -VNetName $vNetName
    if($vNetResult -eq $null -or $vNetResult.OperationStatus -ne "Succeeded")
    {
        throw "Failed to get vNet [$vNetName] for deployment"
    }
    Write-Verbose "Got vNet [$vNetName]"
    

    # Retrieve Subnet name from variable asset if not specified
    if($SubnetName -eq "Use *Default Subnet Name* Variable Value")
    {
        $SubnetName = Get-AutomationVariable -Name "Default Subnet Name"
        $subnetName = $subnetName.ToLower()
        if($SubnetName.length -eq 0)
        {
            Write-Output "ERROR: No Subnet name was specified, and no variable asset with name 'Default SubnetName' was found. Either specify an vNet name or define the default using a variable setting"
            return
        }
    }
    
    # Validate Subnet
    Write-Verbose "Getting Subnet [$SubnetName] for deployment"
    
    #if (!($vNetResult.Subnets.Name.ToLower() -contains $SubnetName))
    #{
    #    throw "Failed to get Subnet [$SubnetName] for deployment"
    #}
    #Write-Verbose "Got subnet [$SubnetName]"
    
	#endregion

	New-WindowsServerToExistingCloudService -VMName $VMName -VMAdminUsername $VMAdminUsername -VMAdminPassword $VMAdminPassword `
											-AzureCredentialName $AzureCredentialName -AzureSubscriptionName $AzureSubscriptionName `
											-CloudServiceName $CloudServiceName -vNetName $vNetName -SubnetName $SubnetName

	Write-Verbose "calling Wait-VM"
	Wait-VM -CloudServiceName $CloudServiceName -VMName $VMName
	
	
	# Import certificate for remote connection to VM
	InlineScript 
	{ 
		Write-Verbose "Getting the WinRM certificate thumbprint for  the VM from Azure"
		$vm = Get-AzureVM -ServiceName $Using:CloudServiceName -Name $Using:VMName
		$winRMCertThumbprint = $vm.VM.DefaultWinRMCertificateThumbprint
		if($winRMCertThumbprint.Length -eq 0)
		{
			throw "Failed to retrieve certificate thumbprint for VM $Using:VMName"
		}

		Write-Verbose "Geting the certificate for VM"
		$certContent = (Get-AzureCertificate -ServiceName $Using:cloudServiceName -Thumbprint $winRMCertThumbprint -ThumbprintAlgorithm sha1).Data
		if($certContent.Length -eq 0)
		{
			throw "Failed to retrieve certificate for VM $Using:VMName"
		}
        
		# Add the VM certificate into the LocalMachine
		Write-Verbose "Adding VM certificate to root store" 
		$certByteArray = [System.Convert]::fromBase64String($certContent) 
		$CertToImport = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2 -ArgumentList (,$certByteArray) 
		$store = New-Object System.Security.Cryptography.X509Certificates.X509Store "Root", "LocalMachine" 
		$store.Open([System.Security.Cryptography.X509Certificates.OpenFlags]::ReadWrite) 
		$store.Add($CertToImport) 
		$store.Close() 
	}

	# Get endpoint for PowerShell remoting and set credentials
	Write-Verbose "Getting remoting endpoint for VM"
	$uri = Get-AzureWinRMUri -ServiceName $CloudServiceName -Name $VMName
	$domainCredential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $DomainAdminUsername,(ConvertTo-SecureString $DomainAdminPassword -AsPlainText -force)

	Write-Verbose "calling Add-ServerToDomain."
	Add-ServerToDomain -CloudServiceName $CloudServiceName -VMName $VMName -DomainName $DomainName -Uri $uri -DomainCredential $domainCredential

	Write-Verbose "calling Wait-VM"
	Wait-VM -CloudServiceName $CloudServiceName -VMName $VMName
	
	Write-Verbose "calling Set-JapaneseLanguage"
	Set-JapaneseLanguage -CloudServiceName $CloudServiceName -VMName $VMName -VMAdminUsername $VMAdminUsername -VMAdminPassword $VMAdminPassword -Uri $uri -DomainCredential $domainCredential
	
	Write-Verbose "finish scripting."

	function Wait-VM {
		Param (
			[parameter(Mandatory=$true)]
			[String]$CloudServiceName,

			[parameter(Mandatory=$true)]
			[String]$VMName,

			[parameter(Mandatory=$false)]
			[Int]$TimeOutMin = 20
		
		)	
		Start-Sleep -Seconds 60
		
		# Wait  for VM provisioning to complete (or time out)
		$timeOut = (Get-Date).AddMinutes($TimeOutMin)
		While ((Get-Date) -lt $timeOut)
		{
			$VMStatus = Get-AzureVM -ServiceName $cloudServiceName -Name $VMName -Verbose:$false | select -ExpandProperty InstanceStatus
			Write-Verbose "Waiting for VM to finish provisioning. Current status is [$VMStatus]"
			if($VMStatus -eq "ReadyRole") 
			{
				Write-Verbose "$VMName is running."
				break
			} 
			Start-Sleep -Seconds 60
		}

		if($VMStatus -ne "ReadyRole")
		{
			throw "Timed out waiting for VM to provision. Last detected VM status was [$VMStatus]"
		}
	}


}	


