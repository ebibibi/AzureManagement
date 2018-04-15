$adminpass = Read-Host -password -AsSecureString
Set-Location c:\CloudDeployment\Setup
.\installAzureStackPOC.ps1 -AdminPassword $adminpass -InfraAzureDirectoryTenantName jbsazsta.onmicrosoft.com -NatIPv4Subnet 172.30.233.0/24 -NatIPv4Address 172.30.233.2 -NatIPv4DefaultGateway 172.30.233.250 -TimeServer 210.173.160.27
