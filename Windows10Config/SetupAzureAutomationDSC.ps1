#PowerShell 1.0にて動作確認しています

#admin check
if (([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
        [Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Output "管理者として実行しています"
}

else {
    Write-Warning "管理者として実行していません。管理者として実行してください。 "
    exit 1
}

$DebugPreference = "SilentlyContinue"

$targetNode = (hostname) #このPowerShellを実行したPC自体を登録する
$subscriptionName = "Visual Studio Ultimate with MSDN"
$resourceGroupName = "Windows10Config"
$location = "Japan East"
$storageAccountName = "win10confstorage"
$storageAccountType = "Standard_LRS"
$automationAccountName = "win10confauto"

$configFilePath = "C:\Users\mebisuda\Dropbox\programming\DSC\Windows10Config\Windows10Config.ps1"
#$configFilePath = (Join-Path -Path $MyInvocation.MyCommand.Path -ChildPath "Windows10Config.ps1")
$confiName = 'Windows10Config.XkeymacsClient'


#ネットワークの場所をPublicからPrivateに変更
Get-NetConnectionProfile |  Where-Object {$_.NetworkCategory -eq "Public"} | Set-NetConnectionProfile -NetworkCategory Private

#WinRM構成
winrm quickconfig -force

#Azureアカウント
#Add-AzureAccount
Login-AzureRmAccount

#reset
#Remove-AzureRmResourceGroup -Name $resourceGroupName -Force

#Subscription
Get-AzureRmSubscription -SubscriptionName $subscriptionName | Select-AzureRmSubscription

#リソースグループ作成
Write-Output "リソースグループを作成します。既に存在している場合にはそれを利用します。"
Write-Output "リソースグループ名 : $resourceGroupName"
$resourceGroup = $null
$ErrorActionPreference = "SilentlyContinue"
$resourceGroup = Get-AzureRmResourceGroup -Name $resourceGroupName -ErrorAction SilentlyContinue
If (!($resourceGroup)) {
    Write-Output "新規に作成します。"
    $resourceGroup = New-AzureRmResourceGroup -Name $resourceGroupName -Location $location 
} Else {
    Write-Output "既存のものを利用します。"
}
$ErrorActionPreference = "Continue"


#Automationアカウント作成
Write-Debug "Automationアカウントを作成します。存在していれば既存のものを利用します。"
Write-Output "Automationアカウント名 : $automationAccountName"
$automationAccount = $null
$ErrorActionPreference = "SilentlyContinue"
$automationAccount = Get-AzureRmAutomationAccount -Name $automationAccountName -ResourceGroupName $resourceGroupName -ErrorAction SilentlyContinue
if(!($automationAccount)) {
    Write-Output "新規に作成します。"
    $automationAccount = New-AzureRmAutomationAccount -Name $automationAccountName -ResourceGroupName $resourceGroupName -Location $location
} else {
    Write-Output "既存のものを利用します。"
}
$ErrorActionPreference = "Continue"



#Publish
Import-AzureRmAutomationDscConfiguration -SourcePath $configFilePath -ResourceGroupName $resourceGroupName -AutomationAccountName $automationAccountName -Published -Force


#Compile
Start-AzureRmAutomationDscCompilationJob -ConfigurationName "Windows10Config" -AutomationAccountName $automationAccountName -ResourceGroupName $resourceGroupName
$jobs = Get-AzureRmAutomationDscCompilationJob -AutomationAccountName $automationAccountName -ResourceGroupName $resourceGroupName
$currentJobID = $jobs[$jobs.Count -1].Id

#Wait for compilation job.
Write-Output "Azure Automation DSC Compilation Job の完了を待ちます"
do
{
    $job = Get-AzureRmAutomationDscCompilationJob -AutomationAccountName $automationAccountName -ResourceGroupName $resourceGroupName -Id $currentJobID
    Write-Debug ("job status : " + $job.Status)
    Start-Sleep 5
} while ($job.EndTime -eq $null)


Get-AzureRmAutomationDscNode -ResourceGroupName $resourceGroupName -AutomationAccountName $automationAccountName
Get-AzureRmAutomationDscNodeConfiguration -ResourceGroupName $resourceGroupName -AutomationAccountName $automationAccountName


#オンプレミスのノードの登録
if(!(Test-Path C:\tmp)) {
    mkdir C:\tmp
}
Get-AzureRmAutomationDscOnboardingMetaconfig -ResourceGroupName $resourceGroupName -AutomationAccountName $automationAccountName -ComputerName $targetNode -OutputFolder C:\tmp -Force
Set-DscLocalConfigurationManager -Path C:\tmp\DscMetaConfigs -ComputerName $targetNode -Verbose #ここでエラーが出る。既知の問題かもしれないので確認する。


#$targetDscNode = Get-AzureRmAutomationDscNode -ResourceGroupName $resourceGroupName -AutomationAccountName $automationAccountName -Name $targetNode
Set-AzureRmAutomationDscNode -Id (Get-DscLocalConfigurationManager).AgentId -NodeConfigurationName  $confiName -ResourceGroupName $resourceGroupName -AutomationAccountName $automationAccountName -Force

#再度設定し直す
Get-AzureRmAutomationDscOnboardingMetaconfig -ResourceGroupName $resourceGroupName -AutomationAccountName $automationAccountName -ComputerName $targetNode -OutputFolder C:\tmp -Force
Set-DscLocalConfigurationManager -Path C:\tmp\DscMetaConfigs -ComputerName $targetNode -Verbose


Get-DscLocalConfigurationManager -CimSession $targetNode
Update-DscConfiguration -CimSession $targetNode -Verbose
$jobs = get-job
$currentJobID = $jobs[$jobs.Count - 1].Id
Receive-Job -Id $currentJobID -keep

Get-DscConfigurationStatus -CimSession $targetNode
Test-DscConfiguration -CimSession $targetNode -Verbose





