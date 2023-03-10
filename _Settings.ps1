$SecretSettings = Get-ObjectFromJSON (Join-Path $PSScriptRoot "_SecretSettings.json") #Secret Settings, stored in a .json file, and ignored by git

if (Test-Path 'D:\DEV-EXT' -PathType Container) {
    $Workspace = 'D:\DEV-EXT'
    $AppFolder = 'D:\DEV-EXT\APP\'
    $AppFolderTest = 'D:\DEV-EXT\APP\TEST\'
    $AppFolderLive = 'D:\DEV-EXT\APP\LIVE\'
}
else {
    $Workspace = 'C:\DEVELOPER'
    $AppFolder = 'C:\DEVELOPER\APP\'
}

$SymbolFolder = '.alpackages'

$dotNetProbingPaths =
"d:\DEV-EXT\bc-common\Common - App\.netpackages",
"C:\Program Files (x86)\Reference Assemblies\Microsoft\Framework\.NETFramework\v4.8",
"C:\Windows\assembly",
"D:\DEV-BASEAPP\BC210-ProgramFiles",
"D:\DEV-BASEAPP\BC210-ProgramFilesX86"

$AppJsons = Get-ChildItem $Workspace -Recurse 'app.json' | Where-Object { $_.PSParentPath -like "*App*" }
$AppJsons += Get-ChildItem $Workspace -Recurse 'app.json' | Where-Object { $_.PSParentPath -like "*Upgrade*" }
$TargetRepos = (Get-ChildItem $Workspace -Recurse -Hidden -Include '.git').Parent.FullName
$Targets = $AppJsons.directory.FullName
#Write-Host $Targets

$ContainerUserName = 'admin'
$ContainerPassword = ConvertTo-SecureString 'ZitP@ssword1' -AsPlainText -Force
$ContainerCredential = New-Object System.Management.Automation.PSCredential ($ContainerUserName, $ContainerPassword)

$UserName = 'sa'
$Password = ConvertTo-SecureString 'ZitP@ssword1' -AsPlainText -Force
$ContainerSqlCredential = New-Object System.Management.Automation.PSCredential ($UserName, $Password)

$ContainerImage = 'mcr.microsoft.com/businesscentral/onprem:w1'
$ContainerLicenseFile = $SecretSettings.containerLicenseFile

#$ContainerAdditionalParameters = @("--env isBcSandbox=Y","--cpu-count 8","--dns=8.8.8.8")
$ContainerAdditionalParameters = @("--cpu-count 8", "--dns=8.8.8.8")

$BCZSFolder = $SecretSettings.ZepterSoftPath
$BCZSAddOnFolder = $SecretSettings.ZepterSoftPathAddOn

$SettingsJson = Get-ObjectFromJSON (Join-Path $Workspace "ps-bc-utils/_SecretSettings.json")
$ContainerCountry = $SettingsJson.country
$ContainerVersion = $SettingsJson.version
$ContainerVersionNewest = $SettingsJson.versionNewest
$ZepterCountry = $SettingsJson.zeptercountry
$ZepterVersion = $SettingsJson.zepterversion

$ContainerName = "$ContainerCountry-bc$($ContainerVersion.Replace('.',''))"
$ContainerNameSaved = $ContainerName
if ($ZepterCountry) {
    $ContainerName = "$ZepterCountry"
}
if ($ZepterVersion) {
    $ContainerName = "$ContainerName-$ZepterVersion"
}
$SyncMode = 'Add'
#$SyncMode = 'Clean'
#$SyncMode = 'Development'
$SyncMode = 'ForceSync'

$AppToInstall = @()
$AppToInstall += 'ZS Common'
$AppToInstall += 'ZS Sales Item'
$AppToInstall += 'ZS Representative'
$AppToInstall += 'ZS Sales Contract'
$AppToInstall += 'ZS Payment'
$AppToInstall += 'ZS Personal Voucher'
$AppToInstall += 'ZS Commission'
$AppToInstall += 'ZS GDPR'
$AppToInstall += 'ZS Import Purchase'
$AppToInstall += 'ZS Holding Report'
$AppToInstall += 'ZS Integration SI'
$AppToInstall += 'ZS Integration MK'
$AppToInstall += 'ZS Integration BA'
$AppToInstall += 'ZS Integration CZ'
$AppToInstall += 'ZS Courier'
$AppToInstall += 'ZS Data Migration'
$AppToInstall += 'ZS Sandbox JAM'
$AppToInstall += 'ESB Integration ZS'
$AppToInstall += 'ESB Integration Temp Fix'
$AppToInstall += 'Designer_35699e84-3a00-48c4-ae73-075a663e0667'

$AppToInstallCount = [array]::IndexOf($AppToInstall,'ZS Common',0) + 1

#Write-Host $AppToInstall
#Write-Host $AppToInstallCount
