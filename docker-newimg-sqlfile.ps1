. (Join-Path $PSScriptRoot '.\_Settings.ps1')
. (Join-Path $PSScriptRoot '.\docker-NewNavServerUser.ps1')
. (Join-Path $PSScriptRoot '.\docker-publish.ps1')

function Docker-NewImg-Sqlfile {
    param (
        [validateset('w1', 'zsi', 'zmk', 'zba', 'zcz', 'zsk', 'zfr', 'zby', 'zpl', 'zhu', 'zjo', 'zuz', 'ita', 'zbg', 'zch', 'zde', 'zlt', 'zus', 'zeg')]
        [String] $ZepterCountryParam = 'w1',
        [validateset('', '10.0', '14.0', '20.0', '22.0', '23.0', '24.0', '25.0', '26.0')]
        [String] $ContainerVersionParam = '20.0',
        [validateset('w1', 'at', 'ca', 'ch', 'cz', 'de', 'fr', 'it', 'ru', 'us')]
        [String] $CountryParam = 'w1',
        [validateset('OnPrem', 'Sandbox')]
        [String] $ContainerType = 'OnPrem',
        [ValidateSet('Latest', 'First', 'All', 'Closest', 'SecondToLastMajor', 'Current', 'NextMinor', 'NextMajor', 'Daily', 'Weekly')]
        [String] $ContainerSelect = 'Latest'
    )

    $ContainerCountry = $CountryParam
    $ServerInstance = 'BC'
    $artifactSelect = $ContainerSelect
    $includeZepterSoft = $false
    $includeZepterSoftAddins = $false
    $containerLicenseFile = $SecretSettings.containerLicenseFile
    $ContainerVersionMajorMinor = $ContainerVersionParam
    $ContainerVersion = $ContainerVersionMajorMinor
    $includeCSIDE = $false
    $auth = 'NavUserPassword'

    if ($ZepterCountryParam -ne 'w1') {
        $ZepterCountry = $ZepterCountryParam
        if ($ZepterCountry) {
            $ContainerName = "$ZepterCountry-live"
        }
        $ContainerCountry = 'w1'
        if ($ZepterCountryParam -in 'zcz', 'zsk') {
            $ContainerCountry = 'cz'
        }
        if ($ZepterCountryParam -in 'zby', 'zuz') {
            $ContainerCountry = 'ru'
        }
        if ($ZepterCountryParam -in 'ita') {
            $ContainerCountry = 'it'
        }
        if ($ZepterCountryParam -eq 'zfr') {
            $ContainerCountry = 'fr'
        }
        if ($ZepterCountryParam -eq 'zch') {
            $ContainerCountry = 'ch'
        }
        if ($ZepterCountryParam -eq 'zde') {
            $ContainerCountry = 'de'
        }
        if ($ZepterCountryParam -eq 'zus') {
            $ContainerCountry = 'na'
        }
        if ($ZepterCountryParam -in 'zpl') {
            $ContainerVersion = '25.1'
            $ContainerVersionMajorMinor = '25.0'
        }
        if ($ZepterCountryParam -in 'zjo', 'zhu', 'zuz', 'ita') {
            $ContainerVersion = '14.17.44663.0'
            $artifactSelect = 'Closest'
            $ContainerVersionMajorMinor = '14.0'
            $includeCSIDE = $true
        }
        if ($ZepterCountryParam -in 'zbg', 'zch', 'zde', 'zlt', 'zus', 'zeg') {
            $ContainerVersion = '10.0.20784.0'
            $artifactSelect = 'Closest'
            $ContainerVersionMajorMinor = '10.0'
            $includeCSIDE = $true
        }
    }

    if ($ContainerVersionMajorMinor -eq '14.0') {
        $ServerInstance = 'NAV'
        $containerLicenseFile = $SecretSettings.containerLicenseFileBC140
        $includeCSIDE = $true
    }
    if ($ContainerVersionMajorMinor -eq '10.0') {
        $ServerInstance = 'NAV'
        $containerLicenseFile = $SecretSettings.containerLicenseFileBC100
        $includeCSIDE = $true
    }

    $params = @{
        'Type'    = $ContainerType
        'Select'  = $artifactSelect
        'Country' = $ContainerCountry
        'Verbose' = 1
    }

    Write-Host ($params | Out-String) -ForegroundColor Yellow

    if (($ZepterCountryParam -ne 'w1') -and ($ContainerType -eq 'OnPrem')) {
        $params += @{ 'Version' = $ContainerVersion }
        $databaseServer = 'sql.host.internal'
        $databaseName = 'NAV_' + $ZepterCountry.ToUpper() + '_' + $ZepterVersion.ToUpper() + '_' + $ContainerVersionMajorMinor.Replace('.', '')
        $ZSSystem = 'ONPREM'
        $includeZepterSoftAddins = $true
    }
    else {
        if (-not ($ContainerSelect -eq "NextMinor" -or $ContainerSelect -eq "NextMajor" -or $ContainerSelect -eq "Current")) {
            $params += @{ 'Version' = $ContainerVersion }
        }
        $ContainerName = "$ContainerCountry-bc$($ContainerVersion.Replace('.',''))"
        $databaseServer = 'localhost'
        $databaseName = 'CRONUS'
        $ZSSystem = 'CLOUD'
    }

    Write-Host ($params | Out-String) -ForegroundColor Yellow

    if ($ContainerType -eq 'OnPrem') {
        $artifactUrl = Get-BCArtifactUrl @params
    }

    if ((-not $artifactUrl)) {
        $params['Type'] = 'Sandbox'
        $params.Remove('Type')
        $params.Remove('version')
        #$params.Remove('Country')
        $params += @{ 'accept_insiderEula' = $true }
        if (-not ($ContainerSelect -eq "NextMinor" -or $ContainerSelect -eq "NextMajor" -or $ContainerSelect -eq "Current")) {
            $params += @{ 'StorageAccount' = 'BcPublicPreview' }
        }
        Write-Host ($params | Out-String) -ForegroundColor Yellow
        $artifactUrl = Get-BCArtifactUrl @params
    }

    Write-Host ($params | Out-String) -ForegroundColor Yellow
    Write-Host $ContainerName 'artifactUrl:' $artifactUrl -ForegroundColor Yellow
    Write-Host $ContainerName $databaseName $databaseInstance -ForegroundColor Yellow
    Write-Host

    $ImageName = $ContainerName

    # >> Default
    $ContainerAlwaysPull = $false
    $ContainerUpdateHosts = $true
    $ContainerForceRebuild = $true

    $assignPremiumPlan = $true
    $enableTaskScheduler = $false
    $enableSymbolLoading = $true

    $includeTestToolkit = $false
    $includeTestLibrariesOnly = $false
    $includePerformanceToolkit = $false
    $includeTestFrameworkOnly = $false
    # << Default
    if (($ContainerVersionMajorMinor -ne '14.0') -and ($ContainerVersionMajorMinor -ne '10.0')) {
        $includeTestToolkit = $true
        $includeTestLibrariesOnly = $true
        $enableSymbolLoading = $false
    }
    #$includePerformanceToolkit = $true
    #$includeTestFrameworkOnly = $true

    $StartMs = Get-Date

    $ContainerParams = @{
        'containerName'             = $ContainerName;
        'artifactUrl'               = $artifactUrl;
        'credential'                = $ContainerCredential;
        'auth'                      = $auth;
        'updateHosts'               = $ContainerUpdateHosts;
        'alwaysPull'                = $ContainerAlwaysPull;
        'includeTestToolkit'        = $includeTestToolkit;
        'includeTestLibrariesOnly'  = $includeTestLibrariesOnly;
        'includePerformanceToolkit' = $includePerformanceToolkit;
        'includeTestFrameworkOnly'  = $includeTestFrameworkOnly;
        'licenseFile'               = $containerLicenseFile;
        'enableTaskScheduler'       = $enableTaskScheduler;
        'forceRebuild'              = $ContainerForceRebuild;
        'assignPremiumPlan'         = $assignPremiumPlan;
        'isolation'                 = 'hyperv';
        'imageName'                 = $ImageName;
        'accept_eula'               = $true;
        'additionalParameters'      = $ContainerAdditionalParameters;
        'doNotExportObjectsToText'  = $true;
        'memoryLimit'               = '8G';
        'shortcuts'                 = 'StartMenu';
        'verbose'                   = $true;
        'includeCSIDE'              = $includeCSIDE;
        'enableSymbolLoading'       = $enableSymbolLoading;
        'multitenant'               = $false;
    }
    if ($ContainerSelect -eq "NextMajor") {
        $ContainerParams += @{ 'accept_insiderEula' = $true }
    }

    if ($ContainerVersionMajorMinor -eq '10.0') {
        $ContainerParams += @{
            'myscripts' = @("https://raw.githubusercontent.com/microsoft/nav-docker/master/override/SelfSignedCertificateEx/SetupCertificate.ps1")
        }
    }

    if ($ZepterCountryParam -ne 'w1') {
        $ContainerParams += @{
            'databaseServer'     = $databaseServer;
            'databaseName'       = $databaseName;
            'databaseCredential' = $ContainerSqlCredential
        }
    }

    Write-Host ($ContainerParams.GetEnumerator() | Sort-Object -Property name | Out-String) -ForegroundColor Yellow

    New-BcContainer @ContainerParams

    if ($ContainerVersionMajorMinor -ne '14.0') {
        if (($includeTestToolkit) -and (!$includeTestLibrariesOnly)) {
            Write-Host 'Uninstall Tests-TestLibraries' -ForegroundColor Yellow
            UnInstall-BcContainerApp -containerName $ContainerName -name "Tests-TestLibraries" -ErrorAction SilentlyContinue
        }
    }

    if ($includeZepterSoftAddins) {
        Invoke-ScriptInBcContainer -containerName $containerName -ScriptBlock {
            $appfile = get-ChildItem -Path 'C:\Program Files' -Filter '*CustomSettings.config' -Recurse -ErrorAction SilentlyContinue
            New-item -itemtype 'directory' -path (join-path $appfile.Directory.FullName '\Add-ins') -name 'ZIT' -ErrorAction SilentlyContinue | Out-Null
        }
        $destServiceFolder = Invoke-ScriptInBcContainer -containerName $containerName -ScriptBlock {
            $appfile = get-ChildItem -Path 'C:\Program Files' -Filter '*CustomSettings.config' -Recurse -ErrorAction SilentlyContinue
            return $appfile.Directory.FullName
        }

        Write-Host '>>>' -ForegroundColor Yellow
        if ($destServiceFolder) {
            Copy-FileToBcContainer `
                -containerName $ContainerName `
                -localPath (join-path $BCZSAddOnFolder "\ClosedXML.dll") `
                -containerPath (join-path $destServiceFolder "\Add-ins\ZIT\ClosedXML.dll")
        }
        Write-Host '<<<' -ForegroundColor Yellow
    }

    if ($includeZepterSoft) {
        Write-host
        Write-host 'ZepterSoft extensions:'
        Write-host

        $Country = ''
        if ($ContainerCountry -eq 'ru') {
            $Country = $ContainerCountry
        }

        PublishExtension `
            -containerName $ContainerName `
            -appName 'ZS Common' `
            -country $Country `
            -system $ZSSystem

        PublishExtension `
            -containerName $ContainerName `
            -appName 'ZS Sales Item'

        PublishExtension `
            -containerName $ContainerName `
            -appName 'ZS Representative'

        $Country = ''
        if (($ContainerCountry -eq 'ru') -or ($ContainerCountry -eq 'cz')) {
            $Country = $ContainerCountry
        }

        PublishExtension `
            -containerName $ContainerName `
            -appName 'ZS Sales Contract' `
            -country $Country
    }

    try {
        if ($ContainerVersionMajorMinor -ne '10.0') {
            Write-Host '>>>' -ForegroundColor Yellow
            Invoke-ScriptInBcContainer -containerName $ContainerName -scriptblock { Param( $ServerInstance )
                Set-NAVServerConfiguration `
                    -ServerInstance $ServerInstance `
                    -KeyName SqlLongRunningThreshold `
                    -KeyValue 2000 `
                    -ApplyTo Memory `
                    -verbose

                #Set-NAVServerInstance -ServerInstance $ServerInstance -Restart -verbose
            } -ArgumentList $ServerInstance
            Write-Host '<<<' -ForegroundColor Yellow

            Write-Host '>>>' -ForegroundColor Yellow
            if (($ContainerVersionMajorMinor -ne '14.0') -and ($ContainerVersionMajorMinor -ne '10.0')) {
                Invoke-ScriptInBcContainer -containerName $ContainerName -scriptblock { Param( $ServerInstance )
                    Set-NAVServerConfiguration `
                        -ServerInstance $ServerInstance `
                        -KeyName SamplingInterval `
                        -KeyValue 1 `
                        -ApplyTo All `
                        -verbose

                    #Set-NAVServerInstance -ServerInstance $ServerInstance -Restart -verbose
                } -ArgumentList $ServerInstance
            }
            elseif ($ContainerVersionMajorMinor -ne '10.0') {
                Invoke-ScriptInBcContainer -containerName $ContainerName -scriptblock { Param( $ServerInstance )
                    Set-NAVServerConfiguration `
                        -ServerInstance $ServerInstance `
                        -KeyName EnableSymbolLoadingAtServerStartup `
                        -KeyValue true `
                        -verbose

                    #Set-NAVServerInstance -ServerInstance $ServerInstance -Restart -verbose
                } -ArgumentList $ServerInstance
            }
            Write-Host '<<<' -ForegroundColor Yellow

            Write-Host '>>>' -ForegroundColor Yellow
            Invoke-ScriptInBcContainer -containerName $ContainerName -scriptblock { Param( $ServerInstance )
                Set-NAVServerInstance -ServerInstance $ServerInstance -Restart -verbose
            } -ArgumentList $ServerInstance
            Write-Host '<<<' -ForegroundColor Yellow
        }
        else {
            if ($ZepterCountryParam -ne 'w1') {
                Write-Host '>>>' -ForegroundColor Yellow
                Docker-NewNavServerUser $ZepterCountryParam
                Write-Host '<<<' -ForegroundColor Yellow
            }
        }
    }
    catch {
        Write-Output "Something threw an exception"
        Write-Output $_
    }

    Write-Host '>>>' -ForegroundColor Yellow
    if ($ZepterCountryParam -ne 'w1') {
        $params = @{ 'ErrorAction' = 'Ignore'; 'ServerInstance' = $databaseServer; 'TrustServerCertificate' = $true }
        $params += @{ 'Username' = $ContainerSqlCredential.UserName; 'Password' = ([System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($ContainerSqlCredential.Password))) }

        $query = "alter DATABASE $databaseName SET QUERY_STORE = ON (OPERATION_MODE = READ_WRITE);"
        Write-Host $query
        Invoke-Sqlcmd @params -Query $query

        $query = "alter DATABASE $databaseName SET QUERY_STORE = ON (WAIT_STATS_CAPTURE_MODE = ON);"
        Write-Host $query
        Invoke-Sqlcmd @params -Query $query
    }
    else {
        Invoke-ScriptInBcContainer -containerName $ContainerName -scriptblock { Param($databaseName)
            $query = "alter DATABASE $databaseName SET QUERY_STORE = ON (OPERATION_MODE = READ_WRITE);"
            Write-Host $query
            Invoke-Sqlcmd -Query $query

            $query = "alter DATABASE $databaseName SET QUERY_STORE = ON (WAIT_STATS_CAPTURE_MODE = ON);"
            Write-Host $query
            Invoke-Sqlcmd -Query $query
        } -ArgumentList $databaseName
    }
    Write-Host '<<<' -ForegroundColor Yellow

    $EndMs = Get-Date
    $Interval = $EndMs - $StartMs

    Write-host
    Write-host "This script took $($Interval.ToString()) to run"
}