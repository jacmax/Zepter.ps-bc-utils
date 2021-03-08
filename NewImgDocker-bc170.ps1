<#
install-module bccontainerhelper -force
Write-NavContainerHelperWelcomeText

The BcContainerHelper PowerShell module contains a function called Get-BcArtifactUrl, which can help you locate the right artifact Url.

The tagging strategy for the businesscentral repository is:

    osversion[-genericversion]

Where

    osversion is the Windows Version number you want to use (e.g. 10.0.19042.844)
    genericversion specify a generic image version number if you want to get anything but the latest public version. If you specify dev you will get the insider build of the generic image.

Examples

    docker pull mcr.microsoft.com/businesscentral:10.0.19042.844         gives you the         Business Central generic image                 based on Windows Servercore 10.0.19042.844
    docker pull mcr.microsoft.com/businesscentral:10.0.19042.844-1.0.0.0 gives you the         Business Central generic image version 1.0.0.0 based on Windows Servercore 10.0.19042.844
    docker pull mcr.microsoft.com/businesscentral:10.0.19042.844-dev     gives you the insider Business Central generic image                 based on Windows Servercore 10.0.19042.844

https://bcartifacts.azureedge.net/sandbox/17.5.22499.22680/w1
https://bcartifacts.azureedge.net/sandbox/17.4.21491.22908/it
https://bcartifacts.azureedge.net/sandbox/17.0.17126.22874/it
https://bcartifacts.azureedge.net/sandbox/17.0.17126.22874/it

docker run `
    -e accept_eula=Y `
    -m 4G `
    -e artifacturl=https://bcartifacts.azureedge.net/sandbox/17.0.17126.22874/it mcr.microsoft.com/dynamicsnav:10.0.19042.630

New-NavContainer -accept_eula `
    -containerName $MyContainer `
    -imageName $MyImageName `
    -licensefile $MyLicense `
    -credential $credential `
    -auth UserPassword `
    -includeCSide `
    -doNotExportObjectsToText
#>

<#
$MyImageName = "microsoft/bcsandbox:it"

New-NavContainer `
    -accept_eula `
    -containerName $MyContainer `
    -imageName $MyImageName `
    -licensefile $MyLicense `
    -credential $credential `
    -auth UserPassword `
    -includeCSide `
    -doNotExportObjectsToText

$artifactUrl = Get-BcArtifactUrl -type sandbox -country it -select latest
$artifactURL = Get-BcArtifactUrl -type sandbox -country it -version 17.0

$artifactUrl = Get-BCArtifactUrl -type OnPrem -country it -select Latest
$artifactURL = Get-BcArtifactUrl -type OnPrem -country it -version 17.0
#>

#$artifactURL = Get-BcArtifactUrl -type OnPrem -country it -version 17.0
#$ContainerName = "it-bc170"

#$artifactURL = Get-BcArtifactUrl -type OnPrem -country it -version 17.4
#$ContainerName = "it-bc174"

$artifactURL = Get-BcArtifactUrl -type OnPrem -country w1 -version 17.4
$ContainerName = "w1-bc174"

$ContainerLicFile = "c:\ProgramData\BcContainerHelper\ZITBC170.flf"
$credential = $null
$password = ConvertTo-SecureString 'ZitP@ssword1' -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential ('admin', $password)

New-BCContainer `
    -accept_eula `
    -containerName $ContainerName `
    -artifactUrl $artifactURL `
    -auth UserPassword `
    -credential $credential `
    -updateHosts `
    -assignPremiumPlan `
    -shortcuts StartMenu `
    -licensefile $ContainerLicFile `
    -EnableTaskSchedule:$false `
    -memoryLimit 8G `
    -includeAL `
    -alwaysPull `
    -isolation hyperv
