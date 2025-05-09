function UnpublishExtension {
    param (
        [String] $ContainerName,
        [String] $AppName
    )
    $oldErrorActionPreference = $ErrorActionPreference
    $ErrorActionPreference = 'Stop'
    Try {
        Get-BcContainerAppInfo -containerName $ContainerName -Tenant Default -TenantSpecificPrope | `
            Where-Object -Property Name -like -Value $AppName | `
            ForEach-Object {
            Try {
                Write-Host -ForegroundColor Green $_.Name $_.Version
                Unpublish-BcContainerApp `
                    -containerName $ContainerName `
                    -name $_.Name `
                    -version $_.Version `
                    -uninstall `
                    -force `
                    -ErrorAction SilentlyContinue
            }
            Finally {
                Write-Host -ForegroundColor Green "Unpublished"
            }
        }
    }
    Catch {
        $ErrorMessage = $_.Exception.Message
        $FailedItem = $_.Exception.ItemName
        Write-Host -ForegroundColor Red "Unpublished of $name on $instance failed! $ErrorMessage"
        Write-Host -ForegroundColor Yellow "$FailedItem"
        Break
    }
    Finally {
        $ErrorActionPreference = $oldErrorActionPreference
    }
}

function PublishExtension {
    param (
        [String] $ContainerName,
        [String] $AppName,
        [String] $Country,
        [String] $System
    )
    Write-Host $ContainerName $AppNAme $Country $System
    if ($Country -eq 'w1') {
        $Country = ''
    }

    $AppNameCountry = $AppName
    if ($Country) {
        $AppNameCountry = $AppName + "_$Country"
    }

    if ($System) {
        $AppNameCountry = $AppNameCountry + "_$System"
    }
    else {
        $AppNameCountry = $AppNameCountry + "_20."
    }
    Write-Host "Get-Item -Path ""$BCZSFolder\*"" -filter ""*${AppNameCountry}*"""
    if ($AppNameCountry) {
        $file = Get-Item -Path "$BCZSFolder\*" -filter "*$AppNameCountry*" | Sort-Object -Property CreationTime | Select-Object -Last 1
    }

    if (-not $file) {
        if ($System) {
            Write-Host "Get-Item -Path ""$BCZSFolder\*"" -filter ""*${AppName}_${System}*"""
            $file = Get-Item -Path "$BCZSFolder\*" -filter "*${AppName}_${System}*" | Sort-Object -Property CreationTime | Select-Object -Last 1
        }
        else {
            $file = Get-Item -Path "$BCZSFolder\*" -filter "*${AppName}_20.*" | Sort-Object -Property CreationTime | Select-Object -Last 1
        }
    }

    if (-not $file) {
        $file = Get-Item -Path "$BCZSFolder\*" -filter "*${AppName}*" | Sort-Object -Property CreationTime | Select-Object -Last 1
    }

    if ($file) {
        Write-Host $file.FullName
        Publish-BcContainerApp `
            -containerName $ContainerName `
            -appFile $file.FullName `
            -install `
            -upgrade `
            -sync `
            -syncMode $SyncMode `
            -SkipVerification
    }
}
