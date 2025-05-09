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
    "C:\Program Files\dotnet\shared\Microsoft.AspNetCore.App\6.0.36",
    "C:\Program Files\dotnet\shared\Microsoft.NETCore.App\6.0.36"
}
if ($SecretSettings.version -eq '24.0') {
    $dotNetProbingPaths =
    "d:\DEV-EXT\bc-common\Common - App\.netpackages",
    "D:\DotNetProbing\BC240-ProgramFiles",
    "D:\DotNetProbing\BC240-ProgramFilesX86",
    "C:\Program Files\dotnet\shared\Microsoft.AspNetCore.App\8.0.5",
    "C:\Program Files\dotnet\shared\Microsoft.NETCore.App\8.0.5"
}
if ($SecretSettings.version -eq '25.0') {
	$system = '25'
    $dotNetProbingPaths =
    "d:\DEV-EXT\bc-common\Common - App\.netpackages",
    "D:\DotNetProbing\BC240-ProgramFiles",
    "D:\DotNetProbing\BC240-ProgramFilesX86",
    "C:\Program Files\dotnet\shared\Microsoft.AspNetCore.App\8.0.5",
    "C:\Program Files\dotnet\shared\Microsoft.NETCore.App\8.0.5"
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
if ($ZepterVersion -and ($ContainerName -ne 'w1-bc260')) {
    $ContainerName = "$ContainerName-$ZepterVersion"
}

$SyncMode = 'Add'
#$SyncMode = 'Clean'
#$SyncMode = 'Development'
$SyncMode = 'ForceSync'

$firstApp = 'ZS Common'
#$firstApp = 'ZS Sales Item'
#$firstApp = 'ZS Representative'
#$firstApp = 'ZS Sales Contract'
#$firstApp = 'ZS Payment'
#$firstApp = 'ZS Personal Voucher'
#$firstApp = 'ZS GDPR'
#$firstApp = 'ZS Service'
#$firstApp = 'ZS Import Purchase'
#$firstApp = 'ZS Courier'
$firstApp = 'ZS Commission'
#$firstApp = 'ZS Integration PL'

$AppToInstall = @()

<#
if ($ZepterCountry -eq 'zpl') { 
	$AppToInstall += 'Polish Localization'
	$AppToInstall += 'Cash Desk Management'
	$AppToInstall += 'Fiscalization Base App'
	$AppToInstall += 'Fiscalization Extension PL'
	$AppToInstall += 'Electronic Banking Base App'
	$AppToInstall += 'Electronic Banking Extension PL'
	$AppToInstall += 'Polish Language (Poland)'
}
#>

if ($ZepterCountry -eq 'w1-bc260') { 
	$AppToInstall += 'Polish Localization'
	$AppToInstall += 'Fiscalization Base App'
	$AppToInstall += 'Fiscalization Extension PL'
}

$AppToInstall += 'ZS Common'
if ($firstApp -eq 'ZS Sales Item') { $AppToInstall = @() }
$AppToInstall += 'ZS Sales Item'
if ($firstApp -eq 'ZS Representative') { $AppToInstall = @() }
$AppToInstall += 'ZS Representative'
if ($firstApp -eq 'ZS Sales Contract') { $AppToInstall = @() }
$AppToInstall += 'ZS Sales Contract'
if ($firstApp -eq 'ZS Payment') { $AppToInstall = @() }
$AppToInstall += 'ZS Payment'
if ($firstApp -eq 'ZS Personal Voucher') { $AppToInstall = @() }
$AppToInstall += 'ZS Personal Voucher'
if ($firstApp -eq 'ZS GDPR') { $AppToInstall = @() }
$AppToInstall += 'ZS GDPR'
if ($firstApp -eq 'ZS Service') { $AppToInstall = @() }
$AppToInstall += 'ZS Service'
if ($firstApp -eq 'ZS Import Purchase') { $AppToInstall = @() }
$AppToInstall += 'ZS Import Purchase'
if ($firstApp -eq 'ZS Courier') { $AppToInstall = @() }
$AppToInstall += 'ZS Courier'
if ($firstApp -eq 'ZS Commission') { $AppToInstall = @() }
$AppToInstall += 'ZS Commission'

if ($ZepterCountry -eq 'zcz') { $AppToInstall += 'ZS Commission Imported' }
if ($ZepterCountry -eq 'zmk') { $AppToInstall += 'ZS Commission Imported' }
if ($ZepterCountry -eq 'zpl') { $AppToInstall += 'ZS Commission Imported' }

if ($ZepterCountry -ne 'w1') { $AppToInstall += 'ZS Holding Report' }

if ($ZepterCountry -eq 'zpl') { 
	if ($firstApp -eq 'ZS Integration PL') { $AppToInstall = @() }	
	$AppToInstall += 'ZS Integration PL' 
	$AppToInstall += 'ESB Integration_'
	$AppToInstall += 'ESB Integration ZS'
}

if ($ZepterCountry -eq 'zjo') { $AppToInstall += 'ZS Integration JO' }
if ($ZepterCountry -eq 'zsi') { $AppToInstall += 'ZS Integration SI' }
if ($ZepterCountry -eq 'zmk') { $AppToInstall += 'ZS Integration MK' }
if ($ZepterCountry -eq 'zba') { $AppToInstall += 'ZS Integration BA' }
if ($ZepterCountry -eq 'zcz') { $AppToInstall += 'ZS Integration CZ' }
if ($ZepterCountry -eq 'zfr') { $AppToInstall += 'ZS Integration FR' }
if ($ZepterCountry -eq 'zfr') { $AppToInstall += 'ZS Upgrade FR' }
if ($ZepterCountry -eq 'zhu') { $AppToInstall += 'ZS Integration HU' }
if ($ZepterCountry -eq 'zhu') { $AppToInstall += 'ZS Migration HU' }

#if ($ZepterCountry -eq 'zcz') { $AppToInstall += 'AC Monetization' }
#if ($ZepterCountry -eq 'zcz') { $AppToInstall += 'AC Financial Pack' }
#if ($ZepterCountry -eq 'zcz') { $AppToInstall += 'AC SK Legislative Pack' }
#if ($ZepterCountry -eq 'zcz') { $AppToInstall += 'AC SK Language Pack' }

if ($ZepterCountry -eq 'zcz') { $AppToInstall += 'ZCZ-Development' }

$AppToInstall += 'ZS Sandbox JAM'

if ($ZepterCountry -ne 'w1-bc260') {
	if (($firstApp -eq 'ZS Common') -or ($UnPublish)) {
		$AppToInstall += 'ZS Data Migration'
		$AppToInstall += 'ZS Sandbox JAM'
		if ($ZepterCountry -ne 'zpl') { 
			$AppToInstall += 'ESB Integration'
			$AppToInstall += 'ESB Integration ZS'
		}
		$AppToInstall += 'ESB Integration Temp Fix'
		$AppToInstall += 'ESB Integration tmp'
		$AppToInstall += 'ESB Data Sender'
		$AppToInstall += 'Designer_35699e84-3a00-48c4-ae73-075a663e0667'
		$AppToInstall += 'Designer_dda0cdb6-f83c-4ca0-9f9e-6cefc720a77a'
		$AppToInstall += 'Designer_3cf8144b-4ea0-4d65-97a6-cbae53be4aad'
		$AppToInstall += 'Designer_39b17ded-af09-4cf3-b319-41d1f671978d'
		$AppToInstall += 'Designer_81b1e062-ceb2-4aa8-b0f5-a5e69b285eb7'
		$AppToInstall += 'Test'
		$AppToInstall += 'ZCZ design pages'
		$AppToInstall += 'Customizations Zepter'

		$AppToInstall += 'ZS-PSW-PL'
		$AppToInstall += 'ZS-PSW-SI'
		$AppToInstall += 'ZS-PSW-TOOL'
		$AppToInstall += 'ZS-JLY-CZ'
		$AppToInstall += 'ZS-JLY-PL'
		$AppToInstall += 'ZS-IJA'
		$AppToInstall += 'ZS-JLY-APP-PL-LIVE'
	}
}
$AppToInstallCount = 0

#if ($ZepterCountry -eq 'zhu') { $AppToInstallCount = 0 }

#if ($ZepterCountry -eq 'zsi') { $AppToInstallCount = 0 }
if ($ZepterCountry -eq 'zsi') { $AppToInstallCount = [array]::IndexOf($AppToInstall, 'ZS Integration SI', 0) + 1 }
#if ($ZepterCountry -eq 'zsi') { $AppToInstallCount = [array]::IndexOf($AppToInstall, 'ZS Personal Voucher', 0) + 1 }
#if ($ZepterCountry -eq 'zsi') { $AppToInstallCount = [array]::IndexOf($AppToInstall, 'ZS Commission', 0) + 1 }

#if ($ZepterCountry -eq 'zmk') { $AppToInstallCount = 0 }
if ($ZepterCountry -eq 'zmk') { $AppToInstallCount = [array]::IndexOf($AppToInstall, 'ZS Integration MK', 0) + 1 }
#if ($ZepterCountry -eq 'zmk') { $AppToInstallCount = [array]::IndexOf($AppToInstall, 'ZS Personal Voucher', 0) + 1 }

#if ($ZepterCountry -eq 'zcz') { $AppToInstallCount = 0 }
if ($ZepterCountry -eq 'zcz') { $AppToInstallCount = [array]::IndexOf($AppToInstall, 'ZS Integration CZ', 0) + 1 }
#if ($ZepterCountry -eq 'zcz') { $AppToInstallCount = [array]::IndexOf($AppToInstall, 'ZS Commission Imported', 0) + 1 }
#if ($ZepterCountry -eq 'zcz') { $AppToInstallCount = [array]::IndexOf($AppToInstall, 'ZS Personal Voucher', 0) + 1 }
#if ($ZepterCountry -eq 'zcz') { $AppToInstallCount = [array]::IndexOf($AppToInstall, 'ZS Commission', 0) + 0 }
#if ($ZepterCountry -eq 'zcz') { $AppToInstallCount = [array]::IndexOf($AppToInstall, 'ZS Sales Contract', 0) + 0 }
#if ($ZepterCountry -eq 'zcz') { $AppToInstallCount = [array]::IndexOf($AppToInstall, 'ZCZ-Development', 0) + 0 }
#if ($ZepterCountry -eq 'zcz') { $AppToInstallCount = [array]::IndexOf($AppToInstall, 'ESB Integration ZS', 0) + 1 }

#if ($ZepterCountry -eq 'zpl') { $AppToInstallCount = [array]::IndexOf($AppToInstall, 'ZS Common', 0) + 0 }
#if ($ZepterCountry -eq 'zpl') { $AppToInstallCount = [array]::IndexOf($AppToInstall, 'ZS Representative', 0) + 0 }
#if ($ZepterCountry -eq 'zpl') { $AppToInstallCount = [array]::IndexOf($AppToInstall, 'ZS Sales Contract', 0) + 0 }
#if ($ZepterCountry -eq 'zpl') { $AppToInstallCount = [array]::IndexOf($AppToInstall, 'ZS Payment', 0) + 0 }
#if ($ZepterCountry -eq 'zpl') { $AppToInstallCount = [array]::IndexOf($AppToInstall, 'ZS Personal Voucher', 0) + 1 }
if ($ZepterCountry -eq 'zpl') { $AppToInstallCount = [array]::IndexOf($AppToInstall, 'ZS Commission', 0) + 0 }
#if ($ZepterCountry -eq 'zpl') { $AppToInstallCount = [array]::IndexOf($AppToInstall, 'ZS Integration PL', 0) + 1 }
#if ($ZepterCountry -eq 'zpl') { $AppToInstallCount = [array]::IndexOf($AppToInstall, 'Polish Language (Poland)', 0) + 1 }

if ($ZepterCountry -eq 'w1-bc260') { $AppToInstallCount = [array]::IndexOf($AppToInstall, 'Fiscalization Extension PL', 0) + 1 }

$AppToInstall2 = @()
#$AppToInstall2 += 'Polish Localization'
#$AppToInstall2 += 'Polish Language (Poland)'

$AppToInstall2 = @()
#$AppToInstall2 += 'Polish Localization_7.1.0.3_runtime_24.4.22295.23546.app'
#$AppToInstallCount = 1

#Write-Host $AppToInstall
#Write-Host $AppToInstallCount
