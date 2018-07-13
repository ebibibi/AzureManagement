param (
    [parameter(mandatory)]
    [string]$email
)

$targetADDirectory = ""
$targetAzureSubscription = ""


Write-Host "You have to connect to AAD Directory($targetADDirectory)"

Import-Module azuread
$azureadmodule = Get-Module azuread
if ($null -eq $azureadmodule) {
    Install-Module azuread -Scope CurrentUser
}

# Connect to Azure AD
try {
    $connection = Get-AzureADTenantDetail
    if ($connection.ObjectId -ne $targetADDirectory) {
        Write-Host "You're connected to different directory. Connect again with different user."
        Connect-AzureAD -TenantId $targetADDirectory
    }
    else {
        Write-Host "You're connected."
    }
} 
catch [Microsoft.Open.Azure.AD.CommonLibrary.AadNeedAuthenticationException] { 
    Write-Host "You're not connected.";
    Connect-AzureAD -TenantId $targetADDirectory
}

$invitation = New-AzureADMSInvitation -InvitedUserEmailAddress $email -InviteRedirectUrl "https://portal.azure.com/" -SendInvitationMessage $true

# Select Subscription
Get-AzureRmSubscription -SubscriptionId $targetAzureSubscription | Select-AzureRmSubscription

# Create RG
New-AzureRMResourceGroup -Name $rgname -Location "Japan East"

# Assign rights
$user = (Get-AzureADUser -ObjectId $invitation.InvitedUser.Id)
if ($null -eq $user) {
    Write-Host "could not get $email from AAD."
}
else {
    New-AzureRmRoleAssignment -SignInName $user.UserPrincipalName -RoleDefinitionName "Contributor" -ResourceGroupName $rgname
}



