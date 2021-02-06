. (Join-Path $PSScriptRoot '_Settings.ps1')

foreach ($Target in $Targets) {
    Write-Host $Target
    Get-ChildItem -Path (Join-Path $Target $SymbolFolder) -Filter '*.app' | % {
        $_ | Remove-Item -Force -Verbose
    }
}

Write-Host $AppFolder
Get-ChildItem -Path $AppFolder -Filter '*.app' | % {
    $_ | Remove-Item -Force -Verbose
}
