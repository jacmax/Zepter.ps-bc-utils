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
        if ($Symbol -notMatch '(CLEAN20|W1)') {
            $ExtensionApp = "$($ExtensionApp)$('_')$Symbol"
        }
    }
    $ExtensionApp = "$($ExtensionApp)$('_')$($AppJson.version)$('.app')"

    $paramProject = @("/project:""$Target""")
    $paramOut = @("/out:""$ExtensionApp""")
    $paramSymbol = @("/packagecachepath:""$(Join-Path $Target $SymbolFolder)""")
    $paramError = @("/errorlog:""$(Join-Path $Target 'error.log')""")

    Write-Host '==='
    Write-Host $Target -ForegroundColor yellow
    Write-Host $AppJson.preprocessorSymbols -ForegroundColor yellow
    Write-Host '==='
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
            $Dependency.version = $CharArray[0] + '.' + $CharArray[1] + '.' + $CharArray[2] + '.*'
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

    if (Test-Path -Path $ExtensionApp -PathType Leaf)
    {
        $TranslationFile = Get-ChildItem -path $ExtensionApp -erroraction 'silentlycontinue'
        if ($TranslationFile) {
            Write-Host "Successfully compiled $ExtensionApp" -ForegroundColor Green -NoNewline
            Write-Host ' (' $AppJson.preprocessorSymbols ')' -ForegroundColor yellow
        }
    }
    else
    {    
        Write-Host "Compilation ended with errors" -ForegroundColor red
    }

    #Write-Host '>>> END Compiling' -ForegroundColor green
    Write-Host ''
}

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

Remove-Item -Path $(Join-Path $AppFolder '*') -Filter "Zepter IT_ZS*.app"
$currentPath = Get-Location
$ClearFolder = $false

$extensions = @()
foreach ($Target in $Targets) {
    #Write-Host 'Folder:' $Target
    if ($ClearFolder -eq $false) {
        Set-Location $Target
        $branch = git branch --show-current
        Write-Host 'Branch:' $branch
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

    if ($application -eq '') {
        if (($AppJson.application -eq '19.0.0.0') -or ($AppJson.application -eq '20.0.0.0')) {
            $application = $AppJson.application;
        }
    }
    if (($country -eq '') -and $AppJson.preprocessorSymbols){
        $country = $AppJson.preprocessorSymbols[1];
    }

    if ($AppJson.preprocessorSymbols -and ($AppJson.application -eq $application) -and ($country -eq $AppJson.preprocessorSymbols[1]) -and (-not $Block)) {
        Write-Host 'AppName:' $AppJson.name
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

$extension = $extensions | Where-Object -Property Name -eq -Value 'ZS Sales Contract'
$extension."Quantity Dependency" -= 4
$extension = $extensions | Where-Object -Property Name -eq -Value 'ZS Payment'
$extension."Quantity Dependency" -= 1
$extension = $extensions | Where-Object -Property Name -eq -Value 'ZS Personal Voucher'
$extension."Quantity Dependency" += 5
$extension = $extensions | Where-Object -Property Name -eq -Value 'ZS GDPR'
$extension."Quantity Dependency" += 0
$extension = $extensions | Where-Object -Property Name -eq -Value 'ZS Integration AT'
$extension."Quantity Dependency" += 0

$extensions = $extensions | Sort-Object -Property 'Quantity Dependency' -Descending
$extensions | Format-Table

foreach ($extension in $extensions) {
    $Target = $extension.Folder
    $Updated = $false
    
    CompileExtension -Target $Target -AppFolder $AppFolder
    
    $AppJsonFile = Get-ChildItem -Path $Target 'app.json'
    $AppJsonFileBakName = $AppJsonFile.Fullname + '.bak'
    Copy-Item -Path $AppJsonFile.Fullname -Destination $AppJsonFileBakName
    
    if ($extension.Name -eq 'ZS Common') {
        App-SwitchCountryTarget -TargetExt $extension.Name -TargetSystem 'CLOUD' 
        CompileExtension -Target $Target -AppFolder $AppFolder
        App-SwitchCountryTarget -TargetExt $extension.Name -TargetCountry 'RU' -TargetSystem 'CLOUD' 
        CompileExtension -Target $Target -AppFolder $AppFolder
        App-SwitchCountryTarget -TargetExt $extension.Name -TargetCountry 'RU' -TargetSystem 'ONPREM' 
        CompileExtension -Target $Target -AppFolder $AppFolder
        $Updated = $true
    }
    if ($extension.Name -eq 'ZS Sales Contract') {
        App-SwitchCountryTarget -TargetExt $extension.Name -TargetCountry 'RU' 
        CompileExtension -Target $Target -AppFolder $AppFolder
        App-SwitchCountryTarget -TargetExt $extension.Name -TargetCountry 'CZ' 
        CompileExtension -Target $Target -AppFolder $AppFolder
        $Updated = $true
    }
    if ($extension.Name -eq 'ZS Personal Voucher') {
        App-SwitchCountryTarget -TargetExt $extension.Name  -TargetSystem 'CLOUD' 
        CompileExtension -Target $Target -AppFolder $AppFolder
        App-SwitchCountryTarget -TargetExt $extension.Name  -TargetSystem 'ONPREM'
        CompileExtension -Target $Target -AppFolder $AppFolder
        $Updated = $true
    }
    if ($Updated) {
        App-SwitchCountryTarget -TargetExt $extension.Name -TargetCountry '' 
        Copy-Item -Path $AppJsonFileBakName -Destination $AppJsonFile.Fullname
    }
    
    Remove-Item $AppJsonFileBakName
}

Set-Location $currentPath
