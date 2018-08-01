workflow Add-ServerToDomain
{
	Param
	(
        [parameter(Mandatory=$true)]
		[String] $CloudServiceName,
		
        [parameter(Mandatory=$true)]
		[String] $VMName,

		[parameter(Mandatory=$true)]
		[String] $DomainName,

		[parameter(Mandatory=$true)]
		[String] $Uri,

		[parameter(Mandatory=$true)]
		$DomainCredential
	)

	Write-Verbose "Add-ServerToDomain start."
	Write-Verbose "try to join [$VMName] to the [$DomainName]"

	$DomainJoinResult = InlineScript
	{
		$commandResult = Invoke-Command -ScriptBlock {
			Param(
				$DomainName,
				$domainCredential
			)
			# Run the following commands in remote session on VM
			try {
				# Record deployment details in log
				$logPath = "C:\DeploymentResults"
				mkdir $logPath
				Start-Transcript -Path "$logPath\Join-Domain.log" -Append
				
				# Disable Network Level Authentication to avoid logon problems after domain deployment
                (Get-WmiObject -class "Win32_TSGeneralSetting" -Namespace root\cimv2\terminalservices -Filter "TerminalName='RDP-tcp'").SetUserAuthenticationRequired(0)
				
				# Join to the domain
				Add-Computer -DomainName $DomainName -Credential $domainCredential -Restart

				Stop-Transcript
			} catch {
				$errorMessage = $error[0].Exception.Message
			}

			if($errorMessage -eq $null)
            {
                return "Success: join domain on VM. See transcript in C:\DeploymentResults on VM for details."
            }
            else
            {
                return "Failed: Encountered error(s) while joining domain on VM. See transcript in C:\DeploymentResults on VM for details. Error message=[$errorMessage]"
            }
            
            # End invoke-command
		} -ConnectionUri $Using:Uri -Credential $Using:domainCredential -ArgumentList $Using:DomainName,$Using:domainCredential
	}
}