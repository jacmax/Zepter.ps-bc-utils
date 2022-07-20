. (Join-path $PSScriptRoot '_Settings.ps1')

Import-Module Microsoft.PowerShell.Utility

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
    if ($ClearFolder -eq $false) {
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

    if ($application -eq '') {
        if (($AppJson.application -eq '19.0.0.0') -or ($AppJson.application -eq '20.0.0.0')) {
            $application = $AppJson.application;
        }
    }
    if ($country -eq '') {
        $country = $AppJson.preprocessorSymbols[1];
    }

    if (($AppJson.application -eq $application) -and ($country -eq $AppJson.preprocessorSymbols[1])) {
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

$extension = $extensions | Where-Object -Property Name -eq -Value 'ZS Personal Voucher'
$extension."Quantity Dependency" += 2
$extension = $extensions | Where-Object -Property Name -eq -Value 'ZS GDPR'
$extension."Quantity Dependency" += 2

$extensions = $extensions | Sort-Object -Property 'Quantity Dependency' -Descending
$extensions | Format-Table

foreach ($extension in $extensions) {
    $Target = $extension.Folder

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

    write-Host '==='
    write-Host $Target -ForegroundColor yellow
    write-Host $AppJson.preprocessorSymbols -ForegroundColor yellow
    write-Host '==='
    write-Host $compilator.fullname
    write-Host $paramProject
    write-Host $paramSymbol
    write-Host $paramError
    write-Host $paramRules
    write-Host $paramOut -ForegroundColor blue
    write-Host $paramAnalyzer
    write-Host $assemblyProbingPaths
    write-Host '==='

    foreach ($Dependency in $AppJson.dependencies) {
        if ($Dependency.publisher -eq 'Zepter IT') {
            $Dependency.version = $Dependency.version.Replace('.0', '.*')
            Write-Host $Dependency.publisher - $Dependency.name - $Dependency.version
            if (Test-Path "$($AppFolder)$($Dependency.publisher)$('_')$($Dependency.name)$('_*')$($Dependency.version)$('.app')") {
                Copy-Item "$($AppFolder)$($Dependency.publisher)$('_')$($Dependency.name)$('_*')$($Dependency.version)$('.app')" -Destination "$($Target)$('\')$($SymbolFolder)"
            }
        }
    }

    if (Test-Path $ExtensionApp) {
        Get-ChildItem -path $ExtensionApp | Remove-Item -Force | Write-Verbose
    }
    write-Host ''
    write-Host '>>> START Compiling' -ForegroundColor green
    Write-Host $compilator.fullname $paramProject $paramSymbol $paramError $paramRules $paramOut $paramAnayzer $assemblyProbingPaths $paramNoWarn  -ForegroundColor Blue
    & $compilator.fullname $paramProject $paramSymbol $paramError $paramRules $paramOut $paramAnayzer $assemblyProbingPaths $paramNoWarn | Write-Verbose
    # | Write-Verbose

    $TranslationFile = Get-ChildItem -path $ExtensionApp
    if ($TranslationFile) {
        Write-Host "Successfully compiled $ExtensionApp" -ForegroundColor Green -NoNewline
        write-Host ' (' $AppJson.preprocessorSymbols ')' -ForegroundColor yellow

    }
    else {
        write-error "Compilation ended with errors"
    }

    write-Host '>>> END Compiling' -ForegroundColor green
    write-Host ''
}

Set-Location $currentPath
