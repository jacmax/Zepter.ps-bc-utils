param (
    [String] $DestFolder = '',
    [String] $BCSystem = ''
)

. (Join-path $PSScriptRoot '_Settings.ps1')
. (Join-path $PSScriptRoot 'app-SwitchCountryTarget.ps1')

Import-Module Microsoft.PowerShell.Utility

function CompileExtension {
    param (
        [String] $Target = '',
        [String] $AppFolder = ''
    )

    #Get app.json
    $AppJson = Get-ObjectFromJSON (Join-Path $Target "app.json")
    $ExtensionApp = $(Join-Path $AppFolder $("$($AppJson.publisher)$('_')$($AppJson.name)"))
    foreach ($Symbol in $AppJson.preprocessorSymbols) {
        if ($Symbol -notMatch '(CLEAN20|CLEAN23|W1)') {
            $ExtensionApp = "$($ExtensionApp)$('_')$Symbol"
        }
    }
    $ExtensionApp = "$($ExtensionApp)$('_')$($AppJson.version)$('.app')"
    $paramProject = @("/project:""$Target""")
    $paramOut = @("/out:""$ExtensionApp""")
    $paramSymbol = @("/packagecachepath:""$(Join-Path $Target $SymbolFolder)""")
    $paramError = @("/errorlog:""$(Join-Path $Target 'error.log')""")

    $BCVersion = $ContainerVersion.Replace('.', '')

    $BaseFolderW1 = "d:\DEV-EXT\app\BC$($BCVersion)\W1\"
    $BaseFolder = $BaseFolderW1

    Remove-Item "$($Target)$('\')$($SymbolFolder)\*.app"
    Copy-Item "$($BaseFolder)Microsoft_*.app" -Destination "$($Target)$('\')$($SymbolFolder)"

    [string] $AppName = $AppJson.name
    if ($AppName.EndsWith('AT')) {
        $BaseFolder = "d:\DEV-EXT\app\BC$($BCVersion)\AT\"
        Remove-Item -Path "$($Target)$('\')$($SymbolFolder)\Microsoft_*.app" -force
        Copy-Item "$($BaseFolder)Microsoft_*.app" -Destination "$($Target)$('\')$($SymbolFolder)"
    }
    if ($AppName.EndsWith('CA') -or $ExtensionApp.Contains('_CA_')) {
        $BaseFolder = "d:\DEV-EXT\app\BC$($BCVersion)\CA\"
        Remove-Item -Path "$($Target)$('\')$($SymbolFolder)\Microsoft_*.app" -force
        Copy-Item "$($BaseFolder)Microsoft_*.app" -Destination "$($Target)$('\')$($SymbolFolder)"
    }
    if ($AppName.EndsWith('CZ') -or $ExtensionApp.Contains('_CZ_')) {
        $BaseFolder = "d:\DEV-EXT\app\BC$($BCVersion)\CZ\"
        Remove-Item -Path "$($Target)$('\')$($SymbolFolder)\Microsoft_*.app" -force
        Copy-Item "$($BaseFolder)Microsoft_*.app" -Destination "$($Target)$('\')$($SymbolFolder)"
    }
    if ($AppName.EndsWith('FR')) {
        $BaseFolder = "d:\DEV-EXT\app\BC$($BCVersion)\FR\"
        Remove-Item -Path "$($Target)$('\')$($SymbolFolder)\Microsoft_*.app" -force
        Copy-Item "$($BaseFolder)Microsoft_*.app" -Destination "$($Target)$('\')$($SymbolFolder)"
    }
    if ($AppName.EndsWith('RU') -or $ExtensionApp.Contains('_RU_')) {
        $BaseFolder = "d:\DEV-EXT\app\BC$($BCVersion)\RU\"
        Remove-Item -Path "$($Target)$('\')$($SymbolFolder)\Microsoft_*.app" -force
        Copy-Item "$($BaseFolder)Microsoft_*.app" -Destination "$($Target)$('\')$($SymbolFolder)"
    }

    Write-Host '==='
    Write-Host $Target -ForegroundColor yellow
    #Write-Host $AppJson.preprocessorSymbols -ForegroundColor yellow
    #Write-Host '==='
    #Write-Host $compilator.fullname
    #Write-Host $paramProject
    #Write-Host $paramSymbol
    #Write-Host $paramError
    #Write-Host $paramRules
    #Write-Host $paramOut -ForegroundColor blue
    #Write-Host $paramAnalyzer
    #Write-Host $assemblyProbingPaths
    #Write-Host '==='

    Remove-Item -Path "$($Target)$('\')$($SymbolFolder)\Zepter IT_ZS*.app" -force
    foreach ($Dependency in $AppJson.dependencies) {
        if ($Dependency.publisher -eq 'Zepter IT') {
            $CharArray = $Dependency.version.Split('.')
            #$Dependency.version = $CharArray[0] + '.' + $CharArray[1] + '.' + $CharArray[2] + '.*'
            $Dependency.version = $CharArray[0] + '.' + $CharArray[1] + '.*' + '.*'
            #Write-Host $Dependency.publisher - $Dependency.name - $Dependency.version
            if (Test-Path "$($AppFolder)$($Dependency.publisher)$('_')$($Dependency.name)$('_*')$($Dependency.version)$('.app')") {
                Copy-Item "$($AppFolder)$($Dependency.publisher)$('_')$($Dependency.name)$('_*')$($Dependency.version)$('.app')" -Destination "$($Target)$('\')$($SymbolFolder)"
            }
        }
    }

    if (Test-Path $ExtensionApp) {
        Get-ChildItem -path $ExtensionApp | Remove-Item -Force | Write-Verbose
    }
    #Write-Host ''
    #Write-Host '>>> START Compiling' -ForegroundColor green
    #Write-Host $compilator.fullname $paramProject $paramSymbol $paramError $paramRules $paramOut $paramAnayzer $assemblyProbingPaths $paramNoWarn  -ForegroundColor Blue
    & $compilator.fullname $paramProject $paramSymbol $paramError $paramRules $paramOut $paramAnayzer $assemblyProbingPaths $paramNoWarn | Write-Verbose
    # | Write-Verbose

    if (-not $AppName.EndsWith('CZ')) {
        Remove-Item "$($Target)$('\')$($SymbolFolder)\M*.app"
        Copy-Item "$($BaseFolderW1)Microsoft_*.app" -Destination "$($Target)$('\')$($SymbolFolder)"
    }

    if (Test-Path -Path $ExtensionApp -PathType Leaf) {
        $TranslationFile = Get-ChildItem -path $ExtensionApp -erroraction 'silentlycontinue'
        if ($TranslationFile) {
            Write-Host "Successfully compiled $ExtensionApp" -ForegroundColor Green -NoNewline
            if ($AppJson.preprocessorSymbols) {
                Write-Host ' (' $AppJson.preprocessorSymbols ')' -ForegroundColor yellow
            }
            else {
                Write-Host
            }
        }
    }
    else {
        Write-Host "Compilation ended with errors" -ForegroundColor red
        Return $false
    }

    #Write-Host '>>> END Compiling' -ForegroundColor green
    #Write-Host '==='
    Return $true
}

if ($BCSystem -eq '') {
    Switch ($SecretSettings.version) {
        '20.0' { $BCSystem = 'BC200' }
        '23.0' { $BCSystem = 'BC230' }
    }
}

Write-Host 'DestFolder:' $DestFolder -ForegroundColor Green
Write-Host 'BCSystem:' $BCSystem -ForegroundColor Green

$application = '';
$country = '';
$compilator = get-childitem -Path "$env:USERPROFILE\.vscode\extensions" -Recurse alc.exe | Select-Object -First 1
$compPath = $compilator.PSParentPath

$paramRules = @("/ruleset:""$Workspace$('\ps-bc-utils\_ForNav.ruleset.json')""")
#$paramNoWarn = @("/nowarn:AL0603")
$paramAnalyzer = @("/analyzer:$(Join-Path $compPath 'Analyzers\Microsoft.Dynamics.Nav.CodeCop.dll')")
$paramAnalyzer += @("/analyzer:$(Join-Path $compPath 'Analyzers\Microsoft.Dynamics.Nav.AppSourceCop.dll')")
$paramAnalyzer += @("/analyzer:$(Join-Path $compPath 'Analyzers\Microsoft.Dynamics.Nav.UICop.dll')")

foreach ($element in $dotNetProbingPaths) {
    $assemblyProbingPaths += @("/assemblyProbingPaths:$element")
}

$currentPath = Get-Location
$ClearFolder = $false

$extensions = @()
foreach ($Target in $Targets) {
    Write-Host 'Folder:' $Target
    if ($ClearFolder -eq $false) {
        Set-Location $Target
        $branch = git branch --show-current
        if ($DestFolder) {
            $branch = $DestFolder
        }
        Write-Host 'Branch:' $branch -ForegroundColor Green
        if ($branch -eq 'develop') {
            Remove-Item -Path $(Join-Path $AppFolderTest '*') -Filter "Zepter IT_ZS*.app"
        }
        if ($branch -eq 'master') {
            Remove-Item -Path $(Join-Path $AppFolderLive '*') -Filter "Zepter IT_ZS*.app"
        }
        $AppFolder = $AppFolderTest
        if ($branch -eq 'master') {
            $AppFolder = $AppFolderLive
        }
        Write-Host 'AppFolder:' $AppFolder
        $ClearFolder = $true
    }

    #Get app.json
    $AppJson = Get-ObjectFromJSON (Join-Path $target "app.json")

    $Block = $AppJson.description -eq 'BLOCK'
    #if ($BCSystem -eq 'BC230' -and $AppJson.name -eq 'ZS Holding Report') {
    #    $Block = $true
    #}
    #if ($BCSystem -eq 'BC230' -and $AppJson.name -ne 'ZS Commission Imported') {
    #    $Block = $true
    #}

    if ($application -eq '') {
        if (($AppJson.application -eq '19.0.0.0') -or ($AppJson.application -eq '20.0.0.0')) {
            $application = $AppJson.application;
        }
    }
    if ($AppJson.application -eq '20.0.0.0') {
        if (-not ( Get-Member -InputObject $AppJson -Name "preprocessorSymbols" )) {
            Add-Member -InputObject $AppJson NoteProperty "preprocessorSymbols" Object[]
            #if ($BCSystem -eq 'BC200') {
            #    $AppJson.preprocessorSymbols += 'CLEAN20'
            #}
            if ($BCSystem -eq 'BC230') {
                $AppJson.preprocessorSymbols += 'CLEAN23'
            }
        }
    }
    if (($country -eq '') -and $AppJson.preprocessorSymbols) {
        $country = $AppJson.preprocessorSymbols[1];
    }
    if ($AppJson.preprocessorSymbols -and ($AppJson.application -eq $application) -and (-not $Block)) {
        #Write-Host 'AppName:' $AppJson.name
        $object = New-Object -TypeName PSObject
        $object | Add-Member -Name 'Name' -MemberType Noteproperty -Value $AppJson.name
        $object | Add-Member -Name 'Folder' -MemberType Noteproperty -Value $Target
        $object | Add-Member -Name 'Quantity Dependency' -MemberType Noteproperty -Value 0

        $extension = $extensions | Where-Object -Property Name -eq -Value $object.Name

        if (!($extension)) {
            $extensions += $object
        }
        else {
            $extension.Folder = $Target
        }

        foreach ($Dependency in $AppJson.dependencies) {
            if ($Dependency.publisher -eq 'Zepter IT') {
                $object = New-Object -TypeName PSObject
                $object | Add-Member -Name 'Name' -MemberType Noteproperty -Value $Dependency.name
                $object | Add-Member -Name 'Folder' -MemberType Noteproperty -Value ''
                $object | Add-Member -Name 'Quantity Dependency' -MemberType Noteproperty -Value 1

                $extension = $extensions | Where-Object -Property Name -eq -Value $object.Name
                if ($extension) {
                    $extension."Quantity Dependency" += 1
                }
                else {
                    $extensions += $object
                }
            }
        }
    }
}

Remove-Item -Path $(Join-Path $AppFolder '*') -Filter "Zepter IT_ZS*.app"

$extension = $extensions | Where-Object -Property Name -eq -Value 'ZS Sales Contract'
$extension."Quantity Dependency" -= 1
$extension = $extensions | Where-Object -Property Name -eq -Value 'ZS Payment'
$extension."Quantity Dependency" -= 0
$extension = $extensions | Where-Object -Property Name -eq -Value 'ZS Personal Voucher'
$extension."Quantity Dependency" += 2
$extension = $extensions | Where-Object -Property Name -eq -Value 'ZS GDPR'
$extension."Quantity Dependency" += 0
$extension = $extensions | Where-Object -Property Name -eq -Value 'ZS Commission Imported'
$extension."Quantity Dependency" += 1
$extension = $extensions | Where-Object -Property Name -eq -Value 'ZS Service'
$extension."Quantity Dependency" += 1
#$extension = $extensions | Where-Object -Property Name -eq -Value 'ZS Integration AT'
#$extension."Quantity Dependency" += 0

$extensions = $extensions | Sort-Object -Property 'Quantity Dependency' -Descending
$extensions | Format-Table

foreach ($extension in $extensions) {
    $Target = $extension.Folder

    if ($Target) {
        $AppJsonFile = Get-ChildItem -Path $Target 'app.json'
        $AppJsonFileBakName = $AppJsonFile.Fullname + '.bak'
        Copy-Item -Path "$($AppJsonFile.Fullname)" -Destination "$AppJsonFileBakName" #-Verbose

        try {
            if ($extension.Name -eq 'ZS Sales Contract') {
                App-SwitchCountryTarget -TargetExt $extension.Name -BCSystem $BCSystem
            }
            else {
                App-SwitchCountryTarget -TargetExt $extension.Name -TargetSystem 'ONPREM' -BCSystem $BCSystem
            }
        }
        catch {
            App-SwitchBCSystemTarget -TargetExt $extension.Name -BCSystem $BCSystem
        }
        if (-not (CompileExtension -Target $Target -AppFolder $AppFolder)) { Exit }

        if ($extension.Name -eq 'ZS Common') {
            Copy-Item -Path $AppJsonFileBakName -Destination $AppJsonFile.Fullname
            App-SwitchCountryTarget -TargetExt $extension.Name -TargetSystem 'CLOUD' -BCSystem $BCSystem
            if (-not (CompileExtension -Target $Target -AppFolder $AppFolder)) { Exit }

            Copy-Item -Path $AppJsonFileBakName -Destination $AppJsonFile.Fullname
            App-SwitchCountryTarget -TargetExt $extension.Name -TargetCountry 'RU' -TargetSystem 'CLOUD' -BCSystem $BCSystem
            if (-not (CompileExtension -Target $Target -AppFolder $AppFolder)) { Exit }

            Copy-Item -Path $AppJsonFileBakName -Destination $AppJsonFile.Fullname
            App-SwitchCountryTarget -TargetExt $extension.Name -TargetCountry 'RU' -TargetSystem 'ONPREM' -BCSystem $BCSystem
            if (-not (CompileExtension -Target $Target -AppFolder $AppFolder)) { Exit }
        }
        if ($extension.Name -eq 'ZS Sales Contract') {
            Copy-Item -Path $AppJsonFileBakName -Destination $AppJsonFile.Fullname
            App-SwitchCountryTarget -TargetExt $extension.Name -TargetCountry 'RU' -BCSystem $BCSystem
            if (-not (CompileExtension -Target $Target -AppFolder $AppFolder)) { Exit }

            Copy-Item -Path $AppJsonFileBakName -Destination $AppJsonFile.Fullname
            App-SwitchCountryTarget -TargetExt $extension.Name -TargetCountry 'CZ' -BCSystem $BCSystem
            if (-not (CompileExtension -Target $Target -AppFolder $AppFolder)) { Exit }
        }
        if ($extension.Name -eq 'ZS Personal Voucher') {
            Copy-Item -Path $AppJsonFileBakName -Destination $AppJsonFile.Fullname
            App-SwitchCountryTarget -TargetExt $extension.Name  -TargetSystem 'CLOUD' -BCSystem $BCSystem
            if (-not (CompileExtension -Target $Target -AppFolder $AppFolder)) { Exit }
        }
        if ($extension.Name -eq 'ZS Integration CZ') {
            Copy-Item -Path $AppJsonFileBakName -Destination $AppJsonFile.Fullname
            App-SwitchCountryTarget -TargetExt $extension.Name  -TargetSystem 'CLOUD' -BCSystem $BCSystem
            if (-not (CompileExtension -Target $Target -AppFolder $AppFolder)) { Exit }
        }
        
        Copy-Item -Path $AppJsonFileBakName -Destination $AppJsonFile.Fullname #-Verbose
        Remove-Item $AppJsonFileBakName #-Verbose
    }
}

Set-Location $currentPath
