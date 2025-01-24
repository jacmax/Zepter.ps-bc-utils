. (Join-Path $PSScriptRoot '.\_Settings.ps1')
function Docker-NewNavServerUser {
    param (
        [validateset('zhu', 'zjo', 'zuz', 'ita', 'zbg', 'zch', 'zde', 'zlt', 'zus', 'zeg')]
        [String] $ZepterCountryParam
    )

    if ($ZepterCountryParam) {
        $containerName = $ZepterCountryParam + '-live'
        Write-Host '>>>' -ForegroundColor Yellow
        Write-Host "Checking user ADMIN in $containerName" -ForegroundColor Green
        Invoke-ScriptInBcContainer -containerName $containerName -scriptblock { Param([PSCredential] $credential)
            $table = Get-NAVServerUser NAV | Where-Object UserName -eq $credential.UserName
            foreach ($row in $table) {
                $user = $row.Item(1)
                Write-Host "User $user exists in $containerName" -ForegroundColor Yellow
            }
            if ($null -eq $user) {
                Write-Host "Add user $($credential.UserName) in $containerName" -ForegroundColor Yellow
                New-NAVServerUser NAV `
                    -UserName $credential.UserName `
                    -Password $credential.Password `
                    -FullName $credential.UserName `
                    -LicenseType 'Full' `
                    -Verbose

                New-NAVServerUserPermissionSet NAV `
                    -UserName $credential.UserName `
                    -PermissionSetId 'SUPER' `
                    -Verbose
            }
        } -argumentList $ContainerCredential
        Write-Host '<<<' -ForegroundColor Yellow

        Write-Host '>>>' -ForegroundColor Yellow
        Write-Host "Checking user SA in $containerName" -ForegroundColor Green
        Invoke-ScriptInBcContainer -containerName $containerName -scriptblock { Param([PSCredential] $credential)
            $table = Get-NAVServerUser NAV | Where-Object UserName -eq $credential.UserName
            foreach ($row in $table) {
                $user = $row.Item(1)
                Write-Host "User $user exists in $containerName" -ForegroundColor Yellow
            }
            if ($null -eq $user) {
                Write-Host "Add user $($credential.UserName) in $containerName" -ForegroundColor Yellow
                New-NAVServerUser NAV `
                    -UserName $credential.UserName `
                    -Password $credential.Password `
                    -FullName $credential.UserName `
                    -LicenseType 'Full' `
                    -Verbose

                New-NAVServerUserPermissionSet NAV `
                    -UserName $credential.UserName `
                    -PermissionSetId 'SUPER' `
                    -Verbose
            }
        } -argumentList $ContainerSqlCredential
        Write-Host '<<<' -ForegroundColor Yellow

    }
}
