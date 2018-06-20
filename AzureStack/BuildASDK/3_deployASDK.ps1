$adminpass = Read-Host -password -AsSecureString
Set-Location c:\CloudDeployment\Setup
.\installAzureStackPOC.ps1 -AdminPassword $adminpass -InfraAzureDirectoryTenantName jbsazsta.onmicrosoft.com -NatIPv4Subnet 172.29.103.0/24 -NatIPv4Address 172.29.103.1 -NatIPv4DefaultGateway 172.29.103.250 -TimeServer 210.173.160.27
