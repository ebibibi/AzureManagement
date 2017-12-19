# To run this script, you have to install "Exchange Online Remote PowerShell module" first.
# See https://technet.microsoft.com/en-us/library/mt775114%28v=exchg.160%29.aspx?f=255&MSPPError=-2147217396
# you have to use Internet Explorer to install the module.
#
# after that, configure winrm
# >winrm get winrm/config/client/auth
# >winrm set winrm/config/client/auth @{Basic="true"}

Param(
    [parameter(mandatory=$true)][string]$outputfile
)

Connect-EXOPSSession | Out-Null

$groups = Get-UnifiedGroup -ResultSize Unlimited

# headers
#$line = "Name,Alias,AccessType,Owners,Members"
$line = "Name,Alias,AccessType,Members"

foreach($group in $groups) {
    $line = $line + "`r`n" + '"' + $group.Name + '",'
    $line = $line + '"' + $group.Alias + '",'
    $line = $line + '"' + $group.AccessType + '",'
    
    # Owners
    #$owners = $group | Get-UnifiedGroupLinks -LinkType Owners
    #$owners
    #$owners_output = '"'
    #foreach($owner in $owners) {
    #    $owners_output = $owners_output + $owner + "`n"
    #}
    #$owners_output = $owners_output + '"'
    #$line = $line + $owners_output + ","
    
    # Members
    $members = $group | Get-UnifiedGroupLinks -LinkType Members
    $members_output = '"'
    foreach($member in $members) {
        $members_output = $members_output + $member + "`n"
    }
    $line = $line + $members_output
    $line = $line + '"'
}

Add-Content -Path $outputfile -Value $line -Encoding String
