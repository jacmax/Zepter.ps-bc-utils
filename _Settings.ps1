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

if ($SecretSettings.version -eq '20.0') {
    $dotNetProbingPaths =
    "d:\DEV-EXT\bc-common\Common - App\.netpackages",
    "C:\Program Files (x86)\Reference Assemblies\Microsoft\Framework\.NETFramework\v4.8",
    "C:\Windows\assembly",
    "D:\DotNetProbing\BC210-ProgramFiles",
    "D:\DotNetProbing\BC210-ProgramFilesX86"
}
if ($SecretSettings.version -eq '23.0') {
    $dotNetProbingPaths =
    "d:\DEV-EXT\bc-common\Common - App\.netpackages",
    "D:\DotNetProbing\BC230-ProgramFiles",
    "D:\DotNetProbing\BC230-ProgramFilesX86",
    "C:\Program Files\dotnet\shared\Microsoft.AspNetCore.App\6.0.27",
    "C:\Program Files\dotnet\shared\Microsoft.NETCore.App\6.0.27"
}

$AppJsons = Get-ChildItem $Workspace -Recurse 'app.json' | Where-Object { $_.PSParentPath -like "*App*" }
$AppJsons += Get-ChildItem $Workspace -Recurse 'app.json' | Where-Object { $_.PSParentPath -like "*Upgrade*" }
$TargetRepos = (Get-ChildItem $Workspace -Recurse -Hidden -Include '.git').Parent.FullName
$Targets = $AppJsons.directory.FullName
#Write-Host $Targets

$TestJsons = Get-ChildItem $Workspace -Recurse 'app.json' | Where-Object { $_.PSParentPath -like "*Test*" }
$TestTargets = $TestJsons.directory.FullName

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

$ContainerCountry = $SecretSettings.country
$ContainerVersion = $SecretSettings.version
$ContainerVersionNewest = $SecretSettings.versionNewest
$ZepterCountry = $SecretSettings.zeptercountry
$ZepterVersion = $SecretSettings.zepterversion

if ($ZepterCountryParam) {
	$ZepterCountry = $ZepterCountryParam
}
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
$AppToInstall += 'ZS Service'
$AppToInstall += 'ZS Import Purchase'
$AppToInstall += 'ZS Holding Report'
if ($ZepterCountry -eq 'zjo') { $AppToInstall += 'ZS Integration JO' }
if ($ZepterCountry -eq 'zsi') { $AppToInstall += 'ZS Integration SI' }
if ($ZepterCountry -eq 'zmk') { $AppToInstall += 'ZS Integration MK' }
if ($ZepterCountry -eq 'zba') { $AppToInstall += 'ZS Integration BA' }
if ($ZepterCountry -eq 'zpl') { $AppToInstall += 'ZS Integration PL' }
if ($ZepterCountry -eq 'zcz') { $AppToInstall += 'ZS Commission Imported' }
if ($ZepterCountry -eq 'zmk') { $AppToInstall += 'ZS Commission Imported' }
if ($ZepterCountry -eq 'zcz') { $AppToInstall += 'ZS Integration CZ' }
if ($ZepterCountry -eq 'zfr') { $AppToInstall += 'ZS Integration FR' }
if ($ZepterCountry -eq 'zfr') { $AppToInstall += 'ZS Upgrade FR' }
if ($ZepterCountry -eq 'zhu') { $AppToInstall += 'ZS Integration HU' }
if ($ZepterCountry -eq 'zhu') { $AppToInstall += 'ZS Migration HU' }
$AppToInstall += 'ZS Courier'
$AppToInstall += 'ZS Data Migration'
$AppToInstall += 'ZS Sandbox JAM'
$AppToInstall += 'ESB Integration ZS'
$AppToInstall += 'ESB Integration Temp Fix'
$AppToInstall += 'ESB Integration tmp'
$AppToInstall += 'Designer_35699e84-3a00-48c4-ae73-075a663e0667'
$AppToInstall += 'Designer_dda0cdb6-f83c-4ca0-9f9e-6cefc720a77a'
$AppToInstall += 'Designer_3cf8144b-4ea0-4d65-97a6-cbae53be4aad'
$AppToInstall += 'Designer_39b17ded-af09-4cf3-b319-41d1f671978d'
$AppToInstall += 'ZCZ design pages'
$AppToInstall += 'ZS-PSW-PL'
$AppToInstall += 'ZS-PSW-SI'
$AppToInstall += 'ZS-PSW-TOOL'
$AppToInstall += 'ZS-JLY-CZ'
$AppToInstall += 'ZS-IJA'
$AppToInstall += 'ZCZ-Development'

$AppToInstallCount = [array]::IndexOf($AppToInstall, 'ZS Service', 0) + 1

if ($ZepterCountry -eq 'zhu') { $AppToInstallCount = 0 }

#if ($ZepterCountry -eq 'zsi') { $AppToInstallCount = 0 }
if ($ZepterCountry -eq 'zsi') { $AppToInstallCount = [array]::IndexOf($AppToInstall, 'ZS Integration SI', 0) + 1 }

#if ($ZepterCountry -eq 'zmk') { $AppToInstallCount = 0 }
if ($ZepterCountry -eq 'zmk') { $AppToInstallCount = [array]::IndexOf($AppToInstall, 'ZS Integration MK', 0) + 1 }
#if ($ZepterCountry -eq 'zmk') { $AppToInstallCount = [array]::IndexOf($AppToInstall, 'ZS Personal Voucher', 0) + 1 }

#if ($ZepterCountry -eq 'zcz') { $AppToInstallCount = 0 }
if ($ZepterCountry -eq 'zcz') { $AppToInstallCount = [array]::IndexOf($AppToInstall, 'ZS Integration CZ', 0) + 1 }
if ($ZepterCountry -eq 'zcz') { $AppToInstallCount = [array]::IndexOf($AppToInstall, 'ZS Commission Imported', 0) + 1 }

#Write-Host $AppToInstall
#Write-Host $AppToInstallCount
