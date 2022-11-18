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
$TargetRepos = (Get-ChildItem $Workspace -Recurse -Hidden -Include '.git').Parent.FullName
$Targets = $AppJsons.directory.FullName

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
#$SyncMode = 'ForceSync'
