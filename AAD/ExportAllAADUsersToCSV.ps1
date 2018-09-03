Connect-AzureAD
$users = Get-AzureADUser -All $true
$users | Select-Object Mail, Surname | Export-csv -NoTypeInformation -Encoding UTF8 c:\tmp\aadusers.csv


