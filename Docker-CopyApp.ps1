#$DockerID = '146d0a79be9c'
$DockerID = 'c22c15982c40'

#$Workspace = 'DEV-EXT'
$Workspace = 'DEV-EXT-BC174'

if ($Workspace -eq 'DEV-EXT') {
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
} else {
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
}

docker stop $($DockerID)

#docker mkdir $($DockerID):/AppZS/

docker cp "D:\$Workspace\APP\Microsoft_Base Application_$BaseAppVer.app" "$($DockerID):/AppZS/"

docker cp "D:\$Workspace\APP\Zepter IT_ZS Common_$CommonAppVer.app" "$($DockerID):/AppZS/"
docker cp "D:\$Workspace\APP\Zepter IT_ZS Sales Item_$SalesItemAppVer.app" "$($DockerID):/AppZS/"
docker cp "D:\$Workspace\APP\Zepter IT_ZS Representative_$RepresentativeAppVer.app" "$($DockerID):/AppZS/"
docker cp "D:\$Workspace\APP\Zepter IT_ZS Sales Contract_$SalesContractAppVer.app" "$($DockerID):/AppZS/"
docker cp "D:\$Workspace\APP\Zepter IT_ZS Payment_$PaymentAppVer.app" "$($DockerID):/AppZS/"
docker cp "D:\$Workspace\APP\Zepter IT_ZS Personal Voucher_$PersonalVoucherAppVer.app" "$($DockerID):/AppZS/"
docker cp "D:\$Workspace\APP\Zepter IT_ZS Commission_$CommissionAppVer.app" "$($DockerID):/AppZS/"
docker cp "D:\$Workspace\APP\Zepter IT_ZS GDPR_$GDPRAppVer.app" "$($DockerID):/AppZS/"
docker cp "D:\$Workspace\APP\Zepter IT_ZS Import Purchase_$ImportPurchaseAppVer.app" "$($DockerID):/AppZS/"
docker cp "D:\$Workspace\APP\Zepter IT_ZS Sample_$SampleAppVer.app" "$($DockerID):/AppZS/"
docker cp "D:\$Workspace\APP\Zepter IT_ZS Service_$ServiceAppVer.app" "$($DockerID):/AppZS/"

#docker cp "D:\$Workspace\APP\NAV_ITA_TEST_170.bak" "$($DockerID):/AppZS/"

docker cp "D:\$Workspace\APP\ZITBC170.flf" "$($DockerID):/AppZS/"
docker cp "D:\DEV-EXT\ps-bc-utils\Docker-InstallApp.ps1" "$($DockerID):/AppZS/"
docker cp "D:\DEV-EXT\ps-bc-utils\Docker-Database-CRONUS.ps1" "$($DockerID):/AppZS/"
docker cp "D:\DEV-EXT\ps-bc-utils\Docker-Database-NAV-ITA-TEST-170.ps1" "$($DockerID):/AppZS/"

docker start $($DockerID)
