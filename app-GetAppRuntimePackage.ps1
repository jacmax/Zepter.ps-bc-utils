$extensions = 'ESB Integration', 'ESB Integration ZS'
$containerName = 'zpl-live'
$navAppInfoFromDbs = Get-BcContainerAppInfo -containerName 'zpl-live' -installedOnly

Foreach ($navAppInfoFromDb in $navAppInfoFromDbs) {
    foreach ($appName in $extensions) {
        if ($navAppInfoFromDb.Name -eq $appName) {
            $appFile = (Join-Path $bcContainerHelperConfig.hostHelperFolder ("Extensions\$containerName\$($appName)_$($navAppInfoFromDb.Version).app" -replace '[~#%&*{}|:<>?/|"]', '_'))
            Get-BcContainerAppRuntimePackage -containerName $containerName `
                -appName $appName -appVersion $navAppInfoFromDb.Version `
                -appFile $appFile `
                -IncludeSourceInPackageFile $true

            Move-Item -Path $appFile -Destination 'd:\DEV-EXT\app\TEST'
        }
    }
}
