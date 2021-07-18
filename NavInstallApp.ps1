param ($InstallBaseApp, $BCVersion)

if ($BCVersion -eq $null) {
  Write-Host 'Please enter BCVersion parameter: BC170, BC180'; 
  Write-Host '';
  Exit;
}

if ($InstallBaseApp -eq $null) {
    $InstallBaseApp = $false;
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
Import-Module 'C:\NAV\Powershell\NavExtensions.ps1'


if ($InstallBaseApp -eq $False) {
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

Get-NAVAppInfo -ServerInstance $BCServerInstance -Tenant Default -TenantSpecificPrope | `
    Sort-Object -Property Name, Version | `
    Format-Table Name, Version, IsInstalled, IsPublished

Write-Host -ForegroundColor Magenta "Unpublish ZS Extensions start  ..."

Get-NAVAppInfo -ServerInstance $BCServerInstance -Tenant Default -TenantSpecificPrope | `
    Where Name -like 'ZS*' | `
    Sort-Object -Property Name, Version | `
    Format-Table Name, Version, IsInstalled, IsPublished

Write-Host -ForegroundColor Yellow "Unpublish ZS Extensions start ..."
Write-Host '============'
Write-Host 'Unpublishing'
Write-Host '============'
Write-Host
UnpublishExtension -Instance $BCServerInstance -Name 'ZS-JAM-Test-001'
UnpublishExtension -Instance $BCServerInstance -Name 'ZS-JLY-Test-001'
UnpublishExtension -Instance $BCServerInstance -Name 'ZS Sandbox JAM'
UnpublishExtension -Instance $BCServerInstance -Name 'ZS Integration IT'
UnpublishExtension -Instance $BCServerInstance -Name 'ZS Holding Report'
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

Write-Host
Write-Host -ForegroundColor Magenta "Unpublish ZS Extensions end  ..."
Write-Host

###############################################################################################################
# Base Application #
####################
if ($InstallBaseApp -eq $True) {
	Write-Host -ForegroundColor Yellow "Uninstall Bases Application start ..."
    $verOld = (GetNavExtensions | Where-Object name -eq 'BaseAppOld').version
	Uninstall-NAVApp -ServerInstance $BCServerInstance -Name "Base Application" -Version $verOld -Force	
	Write-Host -ForegroundColor Yellow "Uninstall Bases Application end ..."
	
    Write-Host -ForegroundColor Yellow "Install Bases Application start ..."
    $verNew = (GetNavExtensions | Where-Object name -eq 'BaseApp').version
	if ($verOld -lt $verNew)
    {
        Publish-NAVApp   -ServerInstance $BCServerInstance -Path (Join-path $InstallFolder "Microsoft_Base Application_$($verNew).app") -SkipVerification
	    Sync-NAVApp      -ServerInstance $BCServerInstance -Name 'Base Application' -Version $verNew -Mode ForceSync -Tenant 'Default' -Force
	    Start-NAVAppDataUpgrade -ServerInstance $BCServerInstance -Name 'Base Application' -Version $verNew -Tenant 'Default'
	    Install-NAVApp   -ServerInstance $BCServerInstance -Name "Base Application" -Version $verNew -Tenant 'Default'
    }
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
Write-Host
Write-Host -ForegroundColor Magenta "Install ZS Extensions start ..."
Write-Host
Write-Host '=========='
Write-Host 'Installing'
Write-Host '=========='
Write-Host
$ver = (GetNavExtensions | Where-Object name -eq 'Common').version
InstallExtension -instance $BCServerInstance -name 'ZS Common'           -version $ver -path (Join-path $InstallFolder "Zepter IT_ZS Common_$($ver).app")
$ver = (GetNavExtensions | Where-Object name -eq 'SalesItem').version
InstallExtension -instance $BCServerInstance -name 'ZS Sales Item'       -version $ver -path (Join-path $InstallFolder "Zepter IT_ZS Sales Item_$($ver).app")
$ver = (GetNavExtensions | Where-Object name -eq 'Representative').version
InstallExtension -instance $BCServerInstance -name 'ZS Representative'   -version $ver -path (Join-path $InstallFolder "Zepter IT_ZS Representative_$($ver).app")
$ver = (GetNavExtensions | Where-Object name -eq 'SalesContract').version
InstallExtension -instance $BCServerInstance -name 'ZS Sales Contract'   -version $ver -path (Join-path $InstallFolder "Zepter IT_ZS Sales Contract_$($ver).app")
$ver = (GetNavExtensions | Where-Object name -eq 'Payment').version
InstallExtension -instance $BCServerInstance -name 'ZS Payment'          -version $ver -path (Join-path $InstallFolder "Zepter IT_ZS Payment_$($ver).app")
$ver = (GetNavExtensions | Where-Object name -eq 'PersonalVoucher').version
InstallExtension -instance $BCServerInstance -name 'ZS Personal Voucher' -version $ver -path (Join-path $InstallFolder "Zepter IT_ZS Personal Voucher_$($ver).app")
$ver = (GetNavExtensions | Where-Object name -eq 'GDPR').version
InstallExtension -instance $BCServerInstance -name 'ZS GDPR'             -version $ver -path (Join-path $InstallFolder "Zepter IT_ZS GDPR_$($ver).app")
$ver = (GetNavExtensions | Where-Object name -eq 'Commission').version
InstallExtension -instance $BCServerInstance -name 'ZS Commission'       -version $ver -path (Join-path $InstallFolder "Zepter IT_ZS Commission_$($ver).app")
$ver = (GetNavExtensions | Where-Object name -eq 'ImportPurchase').version
InstallExtension -instance $BCServerInstance -name 'ZS Import Purchase'  -version $ver -path (Join-path $InstallFolder "Zepter IT_ZS Import Purchase_$($ver).app")
$ver = (GetNavExtensions | Where-Object name -eq 'Sample').version
InstallExtension -instance $BCServerInstance -name 'ZS Sample'           -version $ver -path (Join-path $InstallFolder "Zepter IT_ZS Sample_$($ver).app")
$ver = (GetNavExtensions | Where-Object name -eq 'Service').version
InstallExtension -instance $BCServerInstance -name 'ZS Service'          -version $ver -path (Join-path $InstallFolder "Zepter IT_ZS Service_$($ver).app")
$ver = (GetNavExtensions | Where-Object name -eq 'HoldingReport').version
InstallExtension -instance $BCServerInstance -name 'ZS Holding Report'   -version $ver -path (Join-path $InstallFolder "Zepter IT_ZS Holding Report_$($ver).app")
$ver = (GetNavExtensions | Where-Object name -eq 'ITIntegration').version
InstallExtension -instance $BCServerInstance -name 'ZS Integration IT'   -version $ver -path (Join-path $InstallFolder "Zepter IT_ZS Integration IT_$($ver).app")
Write-Host
Write-Host -ForegroundColor Magenta "Install ZS Extensions end ..."
Write-Host
Write-Host

#######################
# Zepter Soft License #
#######################
Import-NAVServerLicense -ServerInstance $BCServerInstance -LicenseFile $FileLicense

###############################################################################################################
# Restart Services #
####################
Write-Host
Write-Host -ForegroundColor Yellow "Restart services start ..."
Sync-NAVTenant -ServerInstance $BCServerInstance -Mode ForceSync -Force

Restart-NAVServerInstance -ServerInstance $BCServerInstance
Restart-NAVServerInstance -ServerInstance $BCServerInstance2
Write-Host -ForegroundColor Yellow "Restart services end ..."

Get-NAVAppInfo -ServerInstance $BCServerInstance -Tenant Default -TenantSpecificPrope | `
    Where Name -like 'ZS*' | `
    Sort-Object -Property Name, Version | `
    Format-Table Name, Version, IsInstalled, IsPublished
