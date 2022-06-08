$containerName = 'zsi-test'
$password = 'P@ssw0rd'
$securePassword = ConvertTo-SecureString -String $password -AsPlainText -Force
$credential = New-Object pscredential 'admin', $securePassword
$auth = 'UserPassword'
$artifactUrl = Get-BcArtifactUrl -type 'OnPrem' -country 'w1' -select 'Latest' -version '20.0'
$databaseServer = 'host.docker.internal'
$databasePrefix = 'NAV_'
$databaseName = 'NAV_ZSI_TEST_200'
$databaseUsername = 'sa'
$databasePassword = 'ZitP@ssword1'
$databaseSecurePassword = ConvertTo-SecureString -String $databasePassword -AsPlainText -Force
$databaseCredential = New-Object pscredential $databaseUsername, $databaseSecurePassword
$licenseFile = 'd:\ZEPTER\FLF\ZIT\ZITBC200.flf'


New-BcContainer `
    -accept_eula `
    -containerName $containerName `
    -credential $credential `
    -auth $auth `
    -artifactUrl $artifactUrl `
    -imageName 'zsi-test_bc20' `
    -databaseServer $databaseServer -databaseName $databaseName `
    -databaseCredential $databaseCredential `
    -licenseFile $licenseFile `
    -isolation 'hyperv' `
    -memoryLimit 8G `
    -assignPremiumPlan `
    -enableTaskScheduler `
    -includeZepterSoft `
    -updateHosts `
#    -forceRebuild