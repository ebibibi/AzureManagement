Connect-AzureAD
$users = Get-AzureADUser -All $true
$users | Select-Object Mail, Surname, Department, JobTitle | Export-csv -NoTypeInformation -Encoding UTF8 c:\tmp\aadusers.csv


