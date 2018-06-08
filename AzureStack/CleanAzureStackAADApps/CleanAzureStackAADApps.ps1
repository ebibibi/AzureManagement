#remove old AzureStack AAD Applications


#Step 1 - Find the latest Deployment ID
$cred= Get-Credential
$ErcsVM = "enter ip address"
$session = New-PSSession -ComputerName $ErcsVM -ConfigurationName PrivilegedEndpoint -Credential $cred
Enter-PSSession $session
Get-AzureStackStampInformation
#Find\Note the DeploymentID e.g.  18397d52-cf4b-4de0-ad74-3c749916d29a
Exit-PSSession
Get-PSSession | Remove-PSSession

#Step 2 - Use the Deployment ID to identify what AD Applications are being used and which are not
Login-AzureRMAccount
$App = Get-AzureRmADApplication
$App | ?{$_.IdentifierUris -like "https://*/18397d52-cf4b-4de0-ad74-3c749916d29a"} | ft DisplayName,IdentifierUris,ObjectId
$App | ?{$_.IdentifierUris -notlike "https://*/18397d52-cf4b-4de0-ad74-3c749916d29a"} | ft DisplayName,IdentifierUris,ObjectId

#Step 3 - Remove any AD Applications that are not in use
$appsToRemove = $App | ?{$_.IdentifierUris -notlike "https://*/18397d52-cf4b-4de0-ad74-3c749916d29a" -and $_.DisplayName -like "Azure Stack *"}
#Use $appsToRemove | ft DisplayName,IdentifierUris,ObjectId to be sure we are removing the desired apps only. 
foreach ($app in $appsToRemove)
{
    Remove-AzureRmADApplication -ObjectId $app.ObjectId
}
