function App-SwitchCountryTarget {
    param (
        [validateset('ZS Common', 'ZS Sales Contract', 'ZS Personal Voucher')]
        [String] $TargetExt = '',
        [validateset('','CZ','RU')]
        [String] $TargetCountry = '',
        [validateset('','ONPREM','CLOUD')]
        [String] $TargetSystem = ''
    )

    . (Join-path $PSScriptRoot '_Settings.ps1')

    $currentLocation = Get-Location
    if ($TargetExt) {
        foreach ($Target in $Targets) {
            $AppJsonFile = Get-ChildItem -Path $Target 'app.json'
            $AppJson = Get-ObjectFromJSON $AppJsonFile.FullName
            if (($AppJson.application -eq '20.0.0.0') -and $AppJson.name.Contains($TargetExt)) {
                $AppJson.preprocessorSymbols = 'CLEAN20', 'W1'
                if ($TargetCountry) {
                    $AppJson.preprocessorSymbols += $TargetCountry
                }
                if ($TargetSystem) {
                    if ($TargetSystem -eq 'ONPREM') {
                        $AppJson.target = 'OnPrem'
                    }
                    if ($TargetSystem -eq 'CLOUD') {
                        $AppJson.target = 'Cloud'
                        $AppJson.preprocessorSymbols += $TargetSystem
                    }
                }
                $AppJson | ConvertTo-Json -depth 32 | set-content (Join-Path $target "app.json")
            }
        }
    }    
    Set-Location $currentLocation
}