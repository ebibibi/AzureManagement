
# Add the Azure cloud subscription environment name. Supported environment names are AzureCloud or, if using a China Azure Subscription, AzureChinaCloud.
Login-AzureRmAccount -EnvironmentName "AzureCloud"

# select subscription
$subscription = $null

While ($subscription -eq $null) {
    Get-AzureRMSubscription | ft Name, State, SubscriptionId
    $subscriptionID = Read-Host -Prompt "SubscriptionID"
    $subscription = Get-AzureRmSubscription -SubscriptionId $subscriptionID
}

$subscription | Select-AzureRmSubscription

# Register the Azure Stack resource provider in your Azure subscription
Register-AzureRmResourceProvider -ProviderNamespace Microsoft.AzureStack


# download and import the Azure Stack tools
# Change directory to the root directory. 
D:
if (!(Test-Path d:\Tools)) {
    mkdir d:\Tools
}
cd d:\Tools

# Download the tools archive.
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 
invoke-webrequest `
  https://github.com/Azure/AzureStack-Tools/archive/master.zip `
  -OutFile master.zip

# Expand the downloaded files.
expand-archive master.zip `
  -DestinationPath . `
  -Force

# Change to the tools directory.
cd d:\Tools\AzureStack-Tools-master

# import module
Import-Module D:\Tools\AzureStack-Tools-master\Registration\RegisterWithAzure.psm1

#Register Azure Stack
$AzureContext = Get-AzureRmContext
$CloudAdminCred = Get-Credential -UserName AZURESTACK\CloudAdmin -Message "Enter the credentials to access the privileged endpoint."
Set-AzsRegistration `
    -AzureContext $AzureContext `
    -PrivilegedEndpointCredential $CloudAdminCred `
    -PrivilegedEndpoint AzS-ERCS01 `
    -BillingModel Development
