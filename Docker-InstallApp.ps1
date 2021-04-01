param ($loadbaseapp,$installbaseapp)

if ($null -eq $loadbaseapp) {
	$loadbaseapp = $false
}
if ($null -eq $installbaseapp) {
	$installbaseapp = '17.0'
}

Import-Module 'C:\Program Files\Microsoft Dynamics NAV\170\Service\NavAdminTool.ps1'

function InstallExtension
{
    param ($instance, $name, $version, $path)
    Write-Host -ForegroundColor Yellow "$instance"
    Write-Host -ForegroundColor Yellow "$name"
    Write-Host -ForegroundColor Yellow "$version"
    Write-Host -ForegroundColor Yellow "$path"
    $oldErrorActionPreference = $ErrorActionPreference
    $ErrorActionPreference = 'Stop'
    Try
    {
        Publish-NAVApp          -ServerInstance "$instance" -Path "$path" -SkipVerification
        Sync-NAVApp             -ServerInstance "$instance" -Name "$name" -Version "$version" -Mode ForceSync -Tenant 'Default' -force 
        Sync-NAVApp             -ServerInstance "$instance" -Name "$name" -Version "$version" -Tenant 'Default' 
        #Start-NAVAppDataUpgrade -ServerInstance "$instance" -Name "$name" -Version "$version" -Tenant 'Default' 
        Install-NAVApp          -ServerInstance "$instance" -Name "$name" -Version "$version"
    }
    Catch
    {
        $ErrorMessage = $_.Exception.Message
        $FailedItem = $_.Exception.ItemName
        Write-Host -ForegroundColor Red "Instalation of $name on $instance failed! $ErrorMessage"
        Break
    }
    Finally
    {
        Write-Host -ForegroundColor Yellow "Installed ..."
        $ErrorActionPreference = $oldErrorActionPreference
    }
}

Write-Host -ForegroundColor Yellow "$loadbaseapp"
Write-Host -ForegroundColor Yellow "$installbaseapp"

if ($installbaseapp -eq '17.0') {
	Write-Host -ForegroundColor Yellow '">> 17.0'
    $BaseAppVer            = '17.0.16993.1'
    $CommonAppVer          = '0.1.0.0'
    $SalesItemAppVer       = '0.1.0.1'
    $RepresentativeAppVer  = '0.1.0.0'
    $SalesContractAppVer   = '0.1.0.0'
    $PaymentAppVer         = '0.1.0.0'
    $PersonalVoucherAppVer = '0.1.0.0'
    $CommissionAppVer      = '0.1.0.0'
    $GDPRAppVer            = '0.1.0.0'
    $ImportPurchaseAppVer  = '0.1.0.0'
    $SampleAppVer          = '0.1.0.0'
    $ServiceAppVer         = '0.1.0.0'
} elseif ($installbaseapp -eq '17.5') { 
	Write-Host -ForegroundColor Yellow '">> 17.5'
    $BaseAppVer            = '17.5.22500.1'
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

###############################################################################################################
# Uninstall Extensions #
########################

if ($loadbaseapp -eq $true) {
	Uninstall-NAVApp -ServerInstance BC -Name "AMC Banking 365 Fundamentals"
	Uninstall-NAVApp -ServerInstance BC -Name "Company Hub"
	Uninstall-NAVApp -ServerInstance BC -Name "Essential Business Headlines"
	Uninstall-NAVApp -ServerInstance BC -Name "Late Payment Prediction"
	Uninstall-NAVApp -ServerInstance BC -Name "PayPal Payments Standard"
	Uninstall-NAVApp -ServerInstance BC -Name "Sales and Inventory Forecast"
	Uninstall-NAVApp -ServerInstance BC -Name "Send To Email Printer"
	Uninstall-NAVApp -ServerInstance BC -Name "WorldPay Payments Standard"
	Uninstall-NAVApp -ServerInstance BC -Name "_Exclude_APIV2_"
	Uninstall-NAVApp -ServerInstance BC -Name "_Exclude_APIV1_"
	Uninstall-NAVApp -ServerInstance BC -Name "_Exclude_ClientAddIns_"
	Uninstall-NAVApp -ServerInstance BC -Name "Application"
}

Get-NAVAppInfo -ServerInstance BC -Tenant Default | Where Name -like 'ZS*' | Uninstall-NAVApp -ServerInstance BC -Tenant Default -Force

Unpublish-NAVApp -ServerInstance BC -Name 'ZS Service' -Version $ServiceAppVer
Unpublish-NAVApp -ServerInstance BC -Name 'ZS Sample' -Version $SampleAppVer
Unpublish-NAVApp -ServerInstance BC -Name 'ZS Import Purchase' -Version $ImportPurchaseAppVer
Unpublish-NAVApp -ServerInstance BC -Name 'ZS Commission' -Version $CommissionAppVer
Unpublish-NAVApp -ServerInstance BC -Name 'ZS GDPR' -Version $GDPRAppVer
Unpublish-NAVApp -ServerInstance BC -Name 'ZS Personal Voucher' -Version $PersonalVoucherAppVer
Unpublish-NAVApp -ServerInstance BC -Name 'ZS Payment' -Version $PaymentAppVer
Unpublish-NAVApp -ServerInstance BC -Name 'ZS Sales Contract' -Version $SalesContractAppVer
Unpublish-NAVApp -ServerInstance BC -Name 'ZS Representative' -Version $RepresentativeAppVer
Unpublish-NAVApp -ServerInstance BC -Name 'ZS Sales Item' -Version $SalesItemAppVer
Unpublish-NAVApp -ServerInstance BC -Name 'ZS Common' -Version $CommonAppVer

###############################################################################################################
# Base Application #
####################

if ($loadbaseapp -eq $true) {
	Uninstall-NAVApp -ServerInstance BC -Name "Base Application" -Version $BaseAppVer
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
InstallExtension -instance 'BC' -name 'ZS Common'           -version $CommonAppVer          -path "C:\AppZS\Zepter IT_ZS Common_$CommonAppVer.app"
InstallExtension -instance 'BC' -name 'ZS Sales Item'       -version $SalesItemAppVer       -path "C:\AppZS\Zepter IT_ZS Sales Item_$SalesItemAppVer.app"
InstallExtension -instance 'BC' -name 'ZS Representative'   -version $RepresentativeAppVer  -path "C:\AppZS\Zepter IT_ZS Representative_$RepresentativeAppVer.app"
InstallExtension -instance 'BC' -name 'ZS Sales Contract'   -version $SalesContractAppVer   -path "C:\AppZS\Zepter IT_ZS Sales Contract_$SalesContractAppVer.app"
InstallExtension -instance 'BC' -name 'ZS Payment'          -version $PaymentAppVer         -path "C:\AppZS\Zepter IT_ZS Payment_$PaymentAppVer.app"
InstallExtension -instance 'BC' -name 'ZS Personal Voucher' -version $PersonalVoucherAppVer -path "C:\AppZS\Zepter IT_ZS Personal Voucher_$PersonalVoucherAppVer.app"
InstallExtension -instance 'BC' -name 'ZS GDPR'             -version $GDPRAppVer            -path "C:\AppZS\Zepter IT_ZS GDPR_$GDPRAppVer.app"
InstallExtension -instance 'BC' -name 'ZS Commission'       -version $CommissionAppVer      -path "C:\AppZS\Zepter IT_ZS Commission_$CommissionAppVer.app"
InstallExtension -instance 'BC' -name 'ZS Import Purchase'  -version $ImportPurchaseAppVer   -path "C:\AppZS\Zepter IT_ZS Import Purchase_$ImportPurchaseAppVer.app"
InstallExtension -instance 'BC' -name 'ZS Sample'           -version $SampleAppVer          -path "C:\AppZS\Zepter IT_ZS Sample_$SampleAppVer.app"
InstallExtension -instance 'BC' -name 'ZS Service'          -version $ServiceAppVer         -path "C:\AppZS\Zepter IT_ZS Service_$ServiceAppVer.app"

###############################################################################################################
# Restart Services #
####################

#$fn = "C:\AppZS\ZITBC170.flf";
#Import-NAVServerLicense -ServerInstance BC -LicenseFile $fn

Sync-NAVTenant -ServerInstance BC -Mode ForceSync -Force
Restart-NAVServerInstance -ServerInstance BC

#& "C:\Program Files\internet explorer\iexplore.exe" 'http://localhost:8080/BC170'