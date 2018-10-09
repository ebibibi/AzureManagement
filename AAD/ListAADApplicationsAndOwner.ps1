install-module AzureAD | Out-Null
Connect-AzureAD | Out-Null

$applications = Get-AzureADApplication
Write-Output "DiskplayName, ObjectId, AppId, Owner_DisplayName, Owner_UserPrincipalName, Owner_UserType"
foreach($application in $applications) {
    $info = ""
    $owner = $application | Get-AzureADApplicationOwner
    $info = ('"' + $application.DisplayName + '","' + $application.ObjectId + '","' + $application.AppId + '","' + $owner.DisplayName + '","' + $owner.UserPrincipalName + '","' + $owner.UserType + '"')
    Write-Output $info
}