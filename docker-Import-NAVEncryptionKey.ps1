. (Join-Path $PSScriptRoot '.\_Settings.ps1')
function Docker-Import-NAVEncryptionKey {
    param (
        [validateset('w1', 'zsi', 'zmk', 'zba', 'zcz', 'zsk', 'zfr', 'zby', 'zjo', 'zhu', 'zuz', 'ita', 'zbg', 'zch', 'zde', 'zlt', 'zus', 'zeg', 'zpl')]
        [String] $ZepterCountryParam = 'w1',
        [validateset('', '10.0', '14.0', '20.0', '22.0', '23.0', '24.0', '25.0', '26.0')]
        [String] $ContainerVersionParam = '20.0'
    )
    $ServerInstance = 'BC'
    $ContainerName = "$ZepterCountryParam-live"
    if (($ZepterCountryParam -in 'zbg', 'zch', 'zde', 'zlt', 'zus', 'zeg')) {
        $databaseName = "NAV_$($ZepterCountryParam.ToUpper())_LIVE_100"
        $ServerInstance = 'NAV'
        $LicenseFileSrc = $SecretSettings.containerLicenseFileBC100
        $LicenseFileDsc = "d:\BcContainerHelper\Extensions\${ContainerName}\my\license.flf"
    }
    elseif (($ZepterCountryParam -in 'zjo', 'zhu', 'zuz', 'ita')) {
        $databaseName = "NAV_$($ZepterCountryParam.ToUpper())_LIVE_140"
        $ServerInstance = 'NAV'
        $LicenseFileSrc = $SecretSettings.containerLicenseFileBC140
        $LicenseFileDsc = "d:\BcContainerHelper\Extensions\${ContainerName}\my\license.flf"
    }
    elseif (($ZepterCountryParam -in 'zpl')) {
        $databaseName = "NAV_$($ZepterCountryParam.ToUpper())_LIVE_$($ContainerVersionParam.Replace('.',''))"
        $LicenseFileSrc = $SecretSettings.containerLicenseFileBC250
        $LicenseFileDsc = "d:\BcContainerHelper\Extensions\${ContainerName}\my\license.bclicense"
    }
    else {
        $databaseName = "NAV_$($ZepterCountryParam.ToUpper())_LIVE_200"
        $LicenseFileSrc = $SecretSettings.containerLicenseFileBC200
        $LicenseFileDsc = "d:\BcContainerHelper\Extensions\${ContainerName}\my\license.bclicense"
    }

    Copy-Item $LicenseFileSrc $LicenseFileDsc

    Write-Host $databaseName

    Write-Host $ContainerName

    Write-Host '>>>' -ForegroundColor Yellow
    Invoke-ScriptInBcContainer -containerName $ContainerName -scriptblock { Param( $ServerInstance, $sqlCredential, $databaseName )

        Export-NAVEncryptionKey `
            -ServerInstance $ServerInstance `
            -KeyPath "C:\Run\BC.key" `
            -verbose `
            -Force

        Import-NAVEncryptionKey `
            -ServerInstance $ServerInstance `
            -KeyPath "C:\Run\BC.key" `
            -ApplicationDatabaseServer 'sql.host.internal' `
            -ApplicationDatabaseName $databaseName `
            -ApplicationDatabaseCredentials $sqlCredential `
            -verbose `
            -Force

        <#
        Set-NAVServerInstance -ServerInstance $ServerInstance -Start -verbose

        $licenseFile = 'C:\Run\my\license.flf'
        if (Test-Path $licenseFile) {
            Write-Host $licenseFile
            Import-NAVServerLicense `
                -ServerInstance $ServerInstance `
                -LicenseFile $licenseFile `
                -verbose `
                -Force
        }

        $licenseFile = 'C:\Run\my\license.bclicense'
        if (Test-Path $licenseFile) {
            Write-Host $licenseFile
            Import-NAVServerLicense `
                -ServerInstance $ServerInstance `
                -LicenseData $([Byte[]]$(Get-Content -Path $licenseFile -Encoding Byte)) `
                -verbose `
                -Force
        }
        #>

        Set-NAVServerInstance -ServerInstance $ServerInstance -Restart -verbose

    } -ArgumentList $ServerInstance, $ContainerSqlCredential, $databaseName
    Write-Host '<<<' -ForegroundColor Yellow
}