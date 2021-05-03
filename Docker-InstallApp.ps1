param ($loadbaseapp, $installbaseapp)

if ($null -eq $loadbaseapp) {
	$loadbaseapp = $false
}
if ($null -eq $installbaseapp) {
	$installbaseapp = '18.0'
}

Import-Module 'C:\Program Files\Microsoft Dynamics NAV\180\Service\NavAdminTool.ps1'
Import-Module 'C:\AppZS\NavInstallTool.ps1'

Write-Host
Write-Host -ForegroundColor Yellow "Load Base App: $loadbaseapp"
Write-Host -ForegroundColor Yellow "Install Base App: $installbaseapp"

if ($installbaseapp -eq '18.0') {
	Write-Host -ForegroundColor Yellow '>> 18.0'
    $BaseAppVerOld         = '18.0.23013.23795'
    $BaseAppVer            = '18.0.23013.23796'
    $CommonAppVer          = '0.1.0.1'
    $SalesItemAppVer       = '0.1.0.1'
    $RepresentativeAppVer  = '0.1.0.0'
    $SalesContractAppVer   = '0.1.0.1'
    $PaymentAppVer         = '0.1.0.0'
    $PersonalVoucherAppVer = '0.1.0.1'
    $CommissionAppVer      = '0.1.0.3'
    $GDPRAppVer            = '0.1.0.1'
    $ImportPurchaseAppVer  = '0.1.0.1'
    $SampleAppVer          = '0.1.0.0'
    $ServiceAppVer         = '0.1.0.2'
} elseif ($installbaseapp -eq '18.2') { 
	Write-Host -ForegroundColor Yellow '>> 18.5'
    $BaseAppVer            = '18.0.23013.23796'
    $CommonAppVer          = '0.1.0.5'
    $SalesItemAppVer       = '0.1.0.5'
    $RepresentativeAppVer  = '0.1.0.0'
    $SalesContractAppVer   = '0.1.0.5'
    $PaymentAppVer         = '0.1.0.5'
    $PersonalVoucherAppVer = '0.1.0.0'
    $CommissionAppVer      = '0.1.0.5'
    $GDPRAppVer            = '0.1.0.0'
    $ImportPurchaseAppVer  = '0.1.0.0'
    $SampleAppVer          = '0.1.0.0'
    $ServiceAppVer         = '0.1.0.5'
} else {
	Write-Host -ForegroundColor Yellow '">> 00.0'
    $BaseAppVer            = ''
    $CommonAppVer          = ''
    $SalesItemAppVer       = ''
    $RepresentativeAppVer  = ''
    $SalesContractAppVer   = ''
    $PaymentAppVer         = ''
    $PersonalVoucherAppVer = ''
    $CommissionAppVer      = ''
    $GDPRAppVer            = ''
    $ImportPurchaseAppVer  = ''
    $SampleAppVer          = ''
    $ServiceAppVer         = ''
}

Start-NAVServerInstance -ServerInstance BC

Get-NAVAppInfo -ServerInstance BC -Tenant Default -TenantSpecificPrope | Sort-Object -Property Name, Version | Format-Table Name, Version, IsInstalled, IsPublished

###############################################################################################################
# Uninstall Extensions #
########################

if ($loadbaseapp -eq $true) {
	Uninstall-NAVApp -ServerInstance BC -Name "AMC Banking 365 Fundamentals"
#	Uninstall-NAVApp -ServerInstance BC -Name "Company Hub"
	Uninstall-NAVApp -ServerInstance BC -Name "Essential Business Headlines"
	Uninstall-NAVApp -ServerInstance BC -Name "Late Payment Prediction"
	Uninstall-NAVApp -ServerInstance BC -Name "PayPal Payments Standard"
	Uninstall-NAVApp -ServerInstance BC -Name "Sales and Inventory Forecast"
	Uninstall-NAVApp -ServerInstance BC -Name "Send To Email Printer"
	Uninstall-NAVApp -ServerInstance BC -Name "WorldPay Payments Standard"
	Uninstall-NAVApp -ServerInstance BC -Name "_Exclude_APIV2_"
	Uninstall-NAVApp -ServerInstance BC -Name "_Exclude_APIV1_"
	Uninstall-NAVApp -ServerInstance BC -Name "_Exclude_ClientAddIns_"

    Uninstall-NAVApp -ServerInstance BC -Name "Email - Current User Connector"
    Uninstall-NAVApp -ServerInstance BC -Name "Email - Microsoft 365 Connector"
    Uninstall-NAVApp -ServerInstance BC -Name "Email - SMTP Connector"
    Uninstall-NAVApp -ServerInstance BC -Name "Email - Outlook REST API"
    Uninstall-NAVApp -ServerInstance BC -Name "OnPrem Permissions"
    Uninstall-NAVApp -ServerInstance BC -Name "Performance Toolkit"
    Uninstall-NAVApp -ServerInstance BC -Name "Test Runner"
    Uninstall-NAVApp -ServerInstance BC -Name "Simplified Bank Statement Import"
    Uninstall-NAVApp -ServerInstance BC -Name "Universal Print Integration (Preview)"

    Uninstall-NAVApp -ServerInstance BC -Name "JAM-Test-001"
    
	Uninstall-NAVApp -ServerInstance BC -Name "Application"
}

#Get-NAVAppInfo -ServerInstance BC -Tenant Default | `
#    Where Name -like 'ZS*' | `
#    Uninstall-NAVApp -ServerInstance BC -Tenant Default -Force

Get-NAVAppInfo -ServerInstance BC -Tenant Default -TenantSpecificPrope | `
    Where Name -like 'ZS*' | `
    Sort-Object -Property Name, Version | `
    Format-Table Name, Version, IsInstalled, IsPublished

Write-Host '============'
Write-Host 'Unpublishing'
Write-Host '============'
Write-Host
UnpublishExtension -Instance BC -Name 'ZS Service'
UnpublishExtension -Instance BC -Name 'ZS Sample'
UnpublishExtension -Instance BC -Name 'ZS Import Purchase'
UnpublishExtension -Instance BC -Name 'ZS Commission'
UnpublishExtension -Instance BC -Name 'ZS GDPR'
UnpublishExtension -Instance BC -Name 'ZS Personal Voucher'
UnpublishExtension -Instance BC -Name 'ZS Payment'
UnpublishExtension -Instance BC -Name 'ZS Sales Contract'
UnpublishExtension -Instance BC -Name 'ZS Representative'
UnpublishExtension -Instance BC -Name 'ZS Sales Item'
UnpublishExtension -Instance BC -Name 'ZS Common'

Write-Host -ForegroundColor Yellow "Unpublish ZS Extensions end  ..."

###############################################################################################################
# Base Application #
####################

if ($loadbaseapp -eq $true) {
	Uninstall-NAVApp -ServerInstance BC -Name "Base Application" -Version $BaseAppVerOld
	Unpublish-NAVApp -ServerInstance BC -Name "Base Application" -Version $BaseAppVer
	Publish-NAVApp   -ServerInstance BC -Path "C:\AppZS\Microsoft_Base Application_$BaseAppVer.app" -SkipVerification
	Sync-NAVApp      -ServerInstance BC -Name 'Base Application' -Version $BaseAppVer -Mode ForceSync -Tenant 'Default' -Force
	Start-NAVAppDataUpgrade -ServerInstance BC -Name 'Base Application' -Version $BaseAppVer -Tenant 'Default'
	Install-NAVApp   -ServerInstance BC -Name "Base Application" -Version $BaseAppVer

	Install-NAVApp -ServerInstance BC -Name "Application"

	Install-NAVApp -ServerInstance BC -Name "AMC Banking 365 Fundamentals"
	Install-NAVApp -ServerInstance BC -Name "Company Hub"
	Install-NAVApp -ServerInstance BC -Name "Essential Business Headlines"
	Install-NAVApp -ServerInstance BC -Name "Late Payment Prediction"
	Install-NAVApp -ServerInstance BC -Name "PayPal Payments Standard"
	Install-NAVApp -ServerInstance BC -Name "Sales and Inventory Forecast"
	Install-NAVApp -ServerInstance BC -Name "Send To Email Printer"
	Install-NAVApp -ServerInstance BC -Name "WorldPay Payments Standard"
	Install-NAVApp -ServerInstance BC -Name "_Exclude_APIV2_"
	Install-NAVApp -ServerInstance BC -Name "_Exclude_APIV1_"
	Install-NAVApp -ServerInstance BC -Name "_Exclude_ClientAddIns_"
}

###############################################################################################################
# Extensions #
##############
Write-Host -ForegroundColor Yellow "Install ZS Extensions start ..."
Write-Host '=========='
Write-Host 'Installing'
Write-Host '=========='
Write-Host
InstallExtension -instance 'BC' -name 'ZS Common'           -version $CommonAppVer          -path "C:\AppZS\Zepter IT_ZS Common_$CommonAppVer.app"
InstallExtension -instance 'BC' -name 'ZS Sales Item'       -version $SalesItemAppVer       -path "C:\AppZS\Zepter IT_ZS Sales Item_$SalesItemAppVer.app"
InstallExtension -instance 'BC' -name 'ZS Representative'   -version $RepresentativeAppVer  -path "C:\AppZS\Zepter IT_ZS Representative_$RepresentativeAppVer.app"
InstallExtension -instance 'BC' -name 'ZS Sales Contract'   -version $SalesContractAppVer   -path "C:\AppZS\Zepter IT_ZS Sales Contract_$SalesContractAppVer.app"
InstallExtension -instance 'BC' -name 'ZS Payment'          -version $PaymentAppVer         -path "C:\AppZS\Zepter IT_ZS Payment_$PaymentAppVer.app"
InstallExtension -instance 'BC' -name 'ZS Personal Voucher' -version $PersonalVoucherAppVer -path "C:\AppZS\Zepter IT_ZS Personal Voucher_$PersonalVoucherAppVer.app"
InstallExtension -instance 'BC' -name 'ZS GDPR'             -version $GDPRAppVer            -path "C:\AppZS\Zepter IT_ZS GDPR_$GDPRAppVer.app"
InstallExtension -instance 'BC' -name 'ZS Commission'       -version $CommissionAppVer      -path "C:\AppZS\Zepter IT_ZS Commission_$CommissionAppVer.app"
InstallExtension -instance 'BC' -name 'ZS Import Purchase'  -version $ImportPurchaseAppVer  -path "C:\AppZS\Zepter IT_ZS Import Purchase_$ImportPurchaseAppVer.app"
InstallExtension -instance 'BC' -name 'ZS Sample'           -version $SampleAppVer          -path "C:\AppZS\Zepter IT_ZS Sample_$SampleAppVer.app"
InstallExtension -instance 'BC' -name 'ZS Service'          -version $ServiceAppVer         -path "C:\AppZS\Zepter IT_ZS Service_$ServiceAppVer.app"
Write-Host -ForegroundColor Yellow "Install ZS Extensions end ..."

#######################
# Zepter Soft License #
#######################
$fn = "C:\AppZS\ZITBC180.flf";
Import-NAVServerLicense -ServerInstance BC -LicenseFile $fn

###############################################################################################################
# Restart Services #
####################
Write-Host -ForegroundColor Yellow "Restart services start ..."
Sync-NAVTenant -ServerInstance BC -Mode ForceSync -Force

Restart-NAVServerInstance -ServerInstance BC

Write-Host -ForegroundColor Yellow "Restart services end ..."

Get-NAVAppInfo -ServerInstance BC -Tenant Default -TenantSpecificPrope | `
    Where Name -like 'ZS*' | `
    Sort-Object -Property Name, Version | `
    Format-Table Name, Version, IsInstalled, IsPublished

#& "C:\Program Files\internet explorer\iexplore.exe" 'http://localhost:8080/BC180'