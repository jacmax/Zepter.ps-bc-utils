function App-SwitchCountryTarget {
    param (
        [validateset('ZS Common',
            'ZS Sales Contract',
            'ZS Personal Voucher',
            'ZS Courier',
            'ZS Integration CZ')]
        [String] $TargetExt = '',
        [validateset('', 'CZ', 'RU')]
        [String] $TargetCountry = '',
        [validateset('', 'ONPREM', 'CLOUD')]
        [String] $TargetSystem = '',
        [validateset('BC200', 'BC230')]
        [String] $BCSystem = 'BC200'
    )

    . (Join-path $PSScriptRoot '_Settings.ps1')

    $currentLocation = Get-Location
    if ($TargetExt) {
        foreach ($Target in $Targets) {
            $AppJsonFile = Get-ChildItem -Path $Target 'app.json'
            $AppJson = Get-ObjectFromJSON $AppJsonFile.FullName
            if (($AppJson.application -in "20.0.0.0", "23.0.0.0") -and $AppJson.name -eq $TargetExt) {
                #Write-Host $AppJson.name $TargetExt -ForegroundColor Green
                if (-not ( Get-Member -InputObject $AppJson -Name "preprocessorSymbols" )) {
                    Add-Member -InputObject $AppJson NoteProperty "preprocessorSymbols" Object[]
                    $AppJson.preprocessorSymbols = @()
                }
                if (-not $AppJson.preprocessorSymbols.Where{ $_ -eq 'CLEAN20' }) {
                    #if ($BCSystem -eq 'BC200') {
                    #    $AppJson.preprocessorSymbols += 'CLEAN20'
                    #}
                    if ($BCSystem -eq 'BC230') {
                        $AppJson.preprocessorSymbols += 'CLEAN23'
                    }
                }
                if (($TargetCountry) -and (-not $AppJson.preprocessorSymbols.Where{ $_ -eq $TargetCountry })) {
                    $AppJson.preprocessorSymbols += $TargetCountry
                }
                if ($TargetSystem) {
                    #Write-Host 'Target System:' $TargetSystem
                    if ($TargetSystem -eq 'ONPREM') {
                        $AppJson.target = 'OnPrem'
                    }
                    if ($TargetSystem -eq 'CLOUD') {
                        $AppJson.target = 'Cloud'
                        if (-not $AppJson.preprocessorSymbols.Where{ $_ -eq $TargetSystem }) {
                            $AppJson.preprocessorSymbols += $TargetSystem
                        }
                    }
                }

                Switch ($BCSystem) {
                    'BC200' {
                        $version = 20
                        $AppJson.runtime = '9.0'
                    }
                    'BC230' {
                        $version = 23
                        $AppJson.runtime = '12.0'
                    }
                }
                $versionOld = [version]$AppJson.version
                $versionNew = [version]::New($version, $versionOld.Minor, $versionOld.Build, $versionOld.Revision)
                $AppJson.version = $versionNew.ToString()
                foreach ($app in $AppJson.dependencies) {
                    if ($app.publisher -eq 'Zepter IT') {
                        $versionOld = [version]$app.version
                        $versionNew = [version]::New($version, $versionOld.Minor, $versionOld.Build, $versionOld.Revision)
                        $app.version = $versionNew.ToString()
                    }
                }
                $AppJson.platform = [version]::New($version, 0, 0, 0).ToString()
                $AppJson.application = [version]::New($version, 0, 0, 0).ToString()

                $AppJson | ConvertTo-Json -depth 32 | set-content (Join-Path $target "app.json")
            }
        }
    }
    Set-Location $currentLocation
}

function App-SwitchBCSystemTarget {
    param (
        [String] $TargetExt = '',
        [validateset('BC200', 'BC230')]
        [String] $BCSystem = 'BC200'
    )

    . (Join-path $PSScriptRoot '_Settings.ps1')

    $currentLocation = Get-Location
    if ($TargetExt) {
        foreach ($Target in $Targets) {
            $AppJsonFile = Get-ChildItem -Path $Target 'app.json'
            $AppJson = Get-ObjectFromJSON $AppJsonFile.FullName
            if (($AppJson.application -in "20.0.0.0", "23.0.0.0") -and $AppJson.name -eq $TargetExt) {
                #Write-Host $AppJson.name $TargetExt -ForegroundColor Green
                Switch ($BCSystem) {
                    'BC200' {
                        $version = 20
                        $AppJson.runtime = '9.0'
                    }
                    'BC230' {
                        $version = 23
                        $AppJson.runtime = '12.0'
                    }
                }
                $versionOld = [version]$AppJson.version
                $versionNew = [version]::New($version, $versionOld.Minor, $versionOld.Build, $versionOld.Revision)
                $AppJson.version = $versionNew.ToString()
                foreach ($app in $AppJson.dependencies) {
                    if ($app.publisher -eq 'Zepter IT') {
                        $versionOld = [version]$app.version
                        $versionNew = [version]::New($version, $versionOld.Minor, $versionOld.Build, $versionOld.Revision)
                        $app.version = $versionNew.ToString()
                    }
                }
                $AppJson.platform = [version]::New($version, 0, 0, 0).ToString()
                $AppJson.application = [version]::New($version, 0, 0, 0).ToString()

                $AppJson | ConvertTo-Json -depth 32 | set-content (Join-Path $target "app.json")
            }
        }
    }
    Set-Location $currentLocation
}