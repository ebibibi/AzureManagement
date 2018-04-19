# install Azure PowerShell
Install-Module AzureRM

# add-credential
Add-AzureRMAccount -EnvironmentName AzureCloud

# select subscription
$subscription = $null

While ($subscription -eq $null) {
    Get-AzureRMSubscription | ft Name, State, SubscriptionId
    $subscriptionID = Read-Host -Prompt "SubscriptionID"
    $subscription = Get-AzureRmSubscription -SubscriptionId $subscriptionID
}

$subscription | Select-AzureRmSubscription

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
cd d:\Tools\AzureStack-Tools-master\Registration

# Import module
Import-Module .\RegisterWithAzure.psm1
