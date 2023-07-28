param (
    [validateset('OnPrem', 'Cloud')]
    [String] $TargetExt = 'OnPrem'
)

. (Join-path $PSScriptRoot '_Settings.ps1')

$Cloud = $TargetExt -eq 'Cloud'

$currentLocation = Get-Location
foreach ($Target in $Targets) {
    $AppJsonFile = Get-ChildItem -Path $Target 'app.json'
    $AppJson = Get-ObjectFromJSON $AppJsonFile.FullName
    if (($AppJson.application -eq '20.0.0.0') -and $AppJson.name.Contains('ZS ')) {
        $AppJson.target = $TargetExt
        $AppJson.preprocessorSymbols = 'CLEAN20', 'W1'
        if ($AppJson.name -in ('ZS Personal Voucher', 'ZS Common')) {
            if ($Cloud) {
                $AppJson.preprocessorSymbols += 'CLOUD'
            }
        }
        if ((($AppJson.name -ne 'ZS Holding Report') -and
            ($AppJson.name -ne 'ZS Sandbox JAM') -and
            ($AppJson.name -ne 'ZS Data Migration')) -or (-Not $Cloud)) {
            if ($AppJson.resourceExposurePolicy) {
                $AppJson.resourceExposurePolicy.allowDownloadingSource = $false;
                $AppJson.resourceExposurePolicy.includeSourceInSymbolFile = $false;
            }
            $AppJson | ConvertTo-Json -depth 32 | set-content (Join-Path $target "app.json")
            Write-Host $AppJson.version $AppJson.name
        }
    }
}
Set-Location $currentLocation
