param ($InstallBaseApp, $BCVersion)

if ($BCVersion -eq $null) {
  Write-Host 'Please enter BCVersion parameter: BC170, BC180'; 
  Write-Host '';
  Exit;
}

if ($BCVersion -eq 'BC170') {
	Import-Module 'C:\Program Files\Microsoft Dynamics 365 Business Central\170\Service\NavAdminTool.ps1'
	$BCServerInstance  = 'N170_ITA_TEST_17510_TOOL'
	$BCServerInstance2 = 'N170_ITA_TEST_17010'
	$InstallFolder = 'C:\NAV\Install_App_BC180\'
    $FileLicense = "\\plpnavw101\c$\NAV\Licenses\ZIT\ZITBC170.flf";
}	
if ($BCVersion -eq 'BC180') {
	Import-Module 'C:\Program Files\Microsoft Dynamics 365 Business Central\180\Service\NavAdminTool.ps1'
	$BCServerInstance  = 'N180_ITA_TEST_18510_TOOL'
	$BCServerInstance2 = 'N180_ITA_TEST_18010'
	$InstallFolder = 'C:\NAV\Install_App_BC180\'
    $FileLicense = "\\plpnavw101\c$\NAV\Licenses\ZIT\ZITBC180.flf";
}	
Import-Module 'C:\NAV\Powershell\NavInstallTool.ps1'


if ($InstallBaseApp -eq $null) {
  Write-Host '';
  Write-Host -ForegroundColor Red 'Instalation without Base Application'; 
  Write-Host '';
}
if ($InstallBaseApp -eq $True) {
  Write-Host '';
  Write-Host -ForegroundColor Yellow 'Instalation Base Application'; 
  Write-Host '';
}

Start-NAVServerInstance -ServerInstance $BCServerInstance

Get-NAVAppInfo -ServerInstance BC -Tenant Default -TenantSpecificPrope | Sort-Object -Property Name, Version | Format-Table Name, Version, IsInstalled, IsPublished


Write-Host -ForegroundColor Yellow "Unpublish ZS Extensions start  ..."
Get-NAVAppInfo -ServerInstance BC -Tenant Default -TenantSpecificPrope | `
    Where Name -like 'ZS*' | `
    Sort-Object -Property Name, Version | `
    Format-Table Name, Version, IsInstalled, IsPublished

Write-Host '============'
Write-Host 'Unpublishing'
Write-Host '============'
Write-Host
#UnpublishExtension -Instance $BCServerInstance -Name 'JAM-Test-001' -Version 1.0.0.0
UnpublishExtension -Instance $BCServerInstance -Name 'ZS Integration IT'
UnpublishExtension -Instance $BCServerInstance -Name 'ZS Service'
UnpublishExtension -Instance $BCServerInstance -Name 'ZS Sample'
UnpublishExtension -Instance $BCServerInstance -Name 'ZS Import Purchase'
UnpublishExtension -Instance $BCServerInstance -Name 'ZS Commission'
UnpublishExtension -Instance $BCServerInstance -Name 'ZS GDPR'
UnpublishExtension -Instance $BCServerInstance -Name 'ZS Personal Voucher'
UnpublishExtension -Instance $BCServerInstance -Name 'ZS Payment'
UnpublishExtension -Instance $BCServerInstance -Name 'ZS Sales Contract'
UnpublishExtension -Instance $BCServerInstance -Name 'ZS Representative'
UnpublishExtension -Instance $BCServerInstance -Name 'ZS Sales Item'
UnpublishExtension -Instance $BCServerInstance -Name 'ZS Common'

Write-Host -ForegroundColor Yellow "Unpublish ZS Extensions end  ..."

###############################################################################################################
# Base Application #
####################

if ($InstallBaseApp -eq $True) {
	Write-Host -ForegroundColor Yellow "Uninstall Bases Application start ..."
#	Uninstall-NAVApp -ServerInstance $BCServerInstance -Name "Base Application" -Version 18.0.23013.23795
	Uninstall-NAVApp -ServerInstance $BCServerInstance -Name "Base Application" -Version 18.0.23013.23796 -Force	
	Write-Host -ForegroundColor Yellow "Uninstall Bases Application end ..."
	Write-Host -ForegroundColor Yellow "Install Bases Application start ..."
#	Publish-NAVApp   -ServerInstance $BCServerInstance -Path 'Z:\APP\BC180\Microsoft_Base Application_18.0.23013.23796.app' -SkipVerification
#	Sync-NAVApp      -ServerInstance $BCServerInstance -Name 'Base Application' -Version 18.0.23013.23796 -Mode ForceSync -Tenant 'Default' -Force
#	Start-NAVAppDataUpgrade -ServerInstance $BCServerInstance -Name 'Base Application' -Version 18.0.23013.23796 -Tenant 'Default'
	Install-NAVApp   -ServerInstance $BCServerInstance -Name "Base Application" -Version 18.0.23013.23796 -Tenant 'Default'
	Get-NAVAppInfo -ServerInstance $BCServerInstance -Tenant Default -TenantSpecificProperties | `
		Where {`
		$_.Version -Match "^18.*" -and `
		$_.IsPublished -eq $True -and `
		$_.IsInstalled -eq $False -and `
		$_.Name -ne 'Base Application'} | `
		% {Install-NAVApp -ServerInstance $BCServerInstance -Name $_.Name -Version $_.Version -Force}
	Write-Host -ForegroundColor Yellow "Install Bases Application end ..."
}

###############################################################################################################
# Extensions #
##############
Write-Host -ForegroundColor Yellow "Install ZS Extensions start ..."
Write-Host '=========='
Write-Host 'Installing'
Write-Host '=========='
Write-Host
InstallExtension -instance $BCServerInstance -name 'ZS Common'           -version '0.1.0.1' -path (Join-path $InstallFolder 'Zepter IT_ZS Common_0.1.0.1.app')
InstallExtension -instance $BCServerInstance -name 'ZS Sales Item'       -version '0.1.0.1' -path (Join-path $InstallFolder 'Zepter IT_ZS Sales Item_0.1.0.1.app')
InstallExtension -instance $BCServerInstance -name 'ZS Representative'   -version '0.1.0.0' -path (Join-path $InstallFolder 'Zepter IT_ZS Representative_0.1.0.0.app')
InstallExtension -instance $BCServerInstance -name 'ZS Sales Contract'   -version '0.1.0.1' -path (Join-path $InstallFolder 'Zepter IT_ZS Sales Contract_0.1.0.1.app')
InstallExtension -instance $BCServerInstance -name 'ZS Payment'          -version '0.1.0.0' -path (Join-path $InstallFolder 'Zepter IT_ZS Payment_0.1.0.0.app')
InstallExtension -instance $BCServerInstance -name 'ZS Personal Voucher' -version '0.1.0.1' -path (Join-path $InstallFolder 'Zepter IT_ZS Personal Voucher_0.1.0.1.app')
InstallExtension -instance $BCServerInstance -name 'ZS GDPR'             -version '0.1.0.1' -path (Join-path $InstallFolder 'Zepter IT_ZS GDPR_0.1.0.1.app')
InstallExtension -instance $BCServerInstance -name 'ZS Commission'       -version '0.1.0.0' -path (Join-path $InstallFolder 'Zepter IT_ZS Commission_0.1.0.0.app')
InstallExtension -instance $BCServerInstance -name 'ZS Import Purchase'  -version '0.1.0.0' -path (Join-path $InstallFolder 'Zepter IT_ZS Import Purchase_0.1.0.0.app')
InstallExtension -instance $BCServerInstance -name 'ZS Sample'           -version '0.1.0.0' -path (Join-path $InstallFolder 'Zepter IT_ZS Sample_0.1.0.0.app')
InstallExtension -instance $BCServerInstance -name 'ZS Service'          -version '0.1.0.0' -path (Join-path $InstallFolder 'Zepter IT_ZS Service_0.1.0.0.app')
InstallExtension -instance $BCServerInstance -name 'ZS Integration IT'   -version '0.1.0.0' -path (Join-path $InstallFolder 'Zepter IT_ZS Integration IT_0.1.0.0.app')
Write-Host -ForegroundColor Yellow "Install ZS Extensions end ..."

#######################
# Zepter Soft License #
#######################
Import-NAVServerLicense -ServerInstance $BCServerInstance -LicenseFile $FileLicense

####################
# Restart Services #
###############################################################################################################
Write-Host -ForegroundColor Yellow "Restart services start ..."
Sync-NAVTenant -ServerInstance $BCServerInstance -Mode ForceSync -Force

Restart-NAVServerInstance -ServerInstance $BCServerInstance

Restart-NAVServerInstance -ServerInstance $BCServerInstance2
Write-Host -ForegroundColor Yellow "Restart services end ..."
Get-NAVAppInfo -ServerInstance $BCServerInstance -Tenant Default -TenantSpecificPrope | `
	Sort-Object -Property Name, Version | `
	Format-Table Name, Version, IsInstalled, IsPublished 
