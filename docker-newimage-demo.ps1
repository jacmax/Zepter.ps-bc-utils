$artifactUrl = Get-BCArtifactUrl `
    -Type OnPrem `
    -Select Latest `
    -country 'w1' `
    -version '20.0'

$ContainerUserName = 'admin'
$ContainerPassword = ConvertTo-SecureString 'ZitP@ssword1' -AsPlainText -Force
$ContainerCredential = New-Object System.Management.Automation.PSCredential ($ContainerUserName, $ContainerPassword)

$ContainerName = 'BC20'
$ImageName = $ContainerName
$ContainerLicenseFile = "d:/ZITBC200.flf"
$forceRebuild = $true

$StartMs = Get-Date

New-BcContainer `
    -accept_eula `
    -containerName $ContainerName `
    -artifactUrl $artifactUrl `
    -imageName $ImageName `
    -credential $ContainerCredential `
    -auth "UserPassword" `
    -updateHosts `
    -alwaysPull `
    -licenseFile $ContainerLicenseFile `
    -enableTaskScheduler `
    -forceRebuild:$forceRebuild `
    -assignPremiumPlan `
    -isolation hyperv

$EndMs = Get-Date
$Interval = $EndMs - $StartMs

Write-host
Write-host "This script took $($Interval.ToString()) to run"
