#$DebugPreference = "Continue"
$DebugPreference = "SilentlyContinue"

Connect-AzAccount

$subscriptions = Get-AzSubscription -TenantID "cc7dee35-16af-4e40-a4d4-2619d7c0024f"

$resultPublicIPAddresses = @()
foreach($subscription in $subscriptions)
{
    $subscription | Select-AzSubscription
    $publicIPAddresses = Get-AzPublicIpAddress
    foreach($publicIPAddress in $publicIPAddresses)
    {
        $resultPublicIPAddresses += $publicIPAddress
    }
}

$resultPublicIPAddresses | Export-Csv -Path "c:\tmp\AllPublicIpAddresses.csv"

