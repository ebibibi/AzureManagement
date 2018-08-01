configuration Windows10Config
{
	Node 'XkeymacsClient'
	{
		#Registry RightCtrl2CapsLock
		#{
		#	Ensure = "Present"
		#	Key =  "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Keyboard Layout"
		#	ValueName = "Scancode Map"
		#	ValueData = '0000000000000000020000001DE03A0000000000'
		#	ValueType = "Binary"
		#	Force = $true
		#}

        Script RightCtrl2CapsLock
        {
            SetScript = {Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Keyboard Layout" -Name "Scancode Map" -Value ([byte[]](0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x02,0x00,0x00,0x00,0x1D,0xE0,0x3A,0x00,0x00,0x00,0x00,0x00))}
            TestScript = {
                if (Test-Path "HKLM:\SYSTEM\CurrentControlSet\Control\Keyboard Layout\Scancode Map") {
                    $result = (Compare-Object ((Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Keyboard Layout")."Scancode Map") ([byte[]](0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x02,0x00,0x00,0x00,0x1D,0xE0,0x3A,0x00,0x00,0x00,0x00,0x00))).count -eq 0
                } else {
                    $result = $false
                }
                $result
            }
            GetScript = { return @{
                    TestScript = $TestScript
                    SetScript = $SetScript
                    GetScript = $GetScript
                    Result = (Compare-Object ((Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Keyboard Layout")."Scancode Map") ([byte[]](0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x02,0x00,0x00,0x00,0x1D,0xE0,0x3A,0x00,0x00,0x00,0x00,0x00))).count -eq 0
                }
            }
        }

        $services = "WinRM", "Winmgmt"
        foreach($service in $services)
        {
            Service $service
            {
                Name = "WinRM"
                State = "Running"
                StartupType = "Automatic"
            }
        }
	}
}