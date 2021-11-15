$containerName = "it-bc184"
$credential = $null
$password = ConvertTo-SecureString 'ZitP@ssword1' -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential ('admin', $password)
$auth = 'UserPassword'
$artifactUrl = Get-BcArtifactUrl -type OnPrem -country it -version 18.4
$licenseFile = 'd:\ZEPTER\FLF\ZIT\ZITBC190.flf'

New-BcContainer `
    -accept_eula `
    -containerName $containerName `
    -credential $credential `
    -auth $auth `
    -artifactUrl $artifactUrl `
    -imageName $containerName `
    -assignPremiumPlan `
    -shortcuts StartMenu `
    -licenseFile $licenseFile `
    -EnableTaskSchedule:$false `
    -isolation 'hyperv' `
    -memoryLimit 8G `
    -updateHosts `
    -includeAL `
    -alwaysPull `
