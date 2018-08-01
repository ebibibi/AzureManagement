<#
.Synopsis
   This is demo script to reset a pull configuration to push and to force an initial configuration.
.DESCRIPTION
   This is demo script to reset a pull configuration to push and to force an initial configuration.
.EXAMPLE
   Reset-DSCServerConfiguration.ps1 -ComputerName DC1,SRV1
 
.LINK
    http://blog.cosmoskey.com/powershell/desired-state-configuration-in-pull-mode-over-smb

.LINK
    mailto:jakerstrom@gmail.com 

#>
param(
    [ValidateNotNullOrEmpty()]
    [string[]]$ComputerName = @("w813158n151"),
    [ValidateNotNullOrEmpty()]
    [string]$LCMConfigFolder = "C:\tmp\ResetLCM"
)
# create folder for the "reset" configuration

New-Item -Path $LCMConfigFolder -Type directory -Force | out-null

Configuration ResetLCM {
   param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string[]]$ComputerName
    )
    Node $computerName {
        # Just using an empty script resource to create the initial configuration
        # otherwise compuers set to pull without a prior configuration will fail
        # Will log as a bug
        Script FauxConfig {
            SetScript = "''"
            TestScript = '$true'
            GetScript = {@{Result = 'A config exists'}}
        }
        LocalConfigurationManager {
            ConfigurationModeFrequencyMins = 15
            RebootNodeIfNeeded = $False
            RefreshFrequencyMins = 30
            RefreshMode = "PUSH"
        }
    }
}

ResetLCM -ComputerName $ComputerName -OutputPath $LCMConfigFolder 
Set-DscLocalConfigurationManager -Path $LCMConfigFolder 
Start-DscConfiguration -Path $LCMConfigFolder -Wait -Verbose -Force
$cimSession = New-CimSession -ComputerName $ComputerName
Get-DscConfiguration -CimSession $cimSession
