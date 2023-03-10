Import-Module Microsoft.PowerShell.Utility

. (Join-path $PSScriptRoot '_Settings.ps1')
#. ('d:\DEV-EXT\ps-bc-utils\_Settings.ps1')

$compilator = get-childitem -Path "$env:USERPROFILE\.vscode\extensions" -Recurse alc.exe | select -First 1
$compPath = $compilator.PSParentPath

$paramRules    = @('/ruleset:"'+$Workspace+$("\ps-bc-utils\_ForNav.ruleset.json")+'"')
$paramNoWarn   = $null
$paramAnalyzer = @('/analyzer:"'+$(Join-Path $compPath "Analyzers\Microsoft.Dynamics.Nav.CodeCop.dll")+'"')
$paramAnalyzer += @('/analyzer:"'+$(Join-Path $compPath "Analyzers\Microsoft.Dynamics.Nav.AppSourceCop.dll")+'"')
$paramAnalyzer += @('/analyzer:"'+$(Join-Path $compPath "Analyzers\Microsoft.Dynamics.Nav.UICop.dll")+'"')

$assemblyProbingPaths = $null
foreach ($element in $dotNetProbingPaths) {
    $assemblyProbingPaths += @("/assemblyProbingPaths:$element")
}

Remove-Item -Path $(Join-Path $AppFolder '*') -Filter "Zepter IT_ZS*.app"

$currentPath = Get-Location
$ClearFolder = $false

$Targets = @('d:\DEV-EXT\bc-integration-hu\Integration HU - App','d:\DEV-EXT\bc-integration-hu\Translation HU')

foreach ($Target in $Targets) {
    Set-Location $Target
    $branch = git branch --show-current
    if ($ClearFolder -eq $false)
    {
        if ($branch -eq 'develop')
        {
            Remove-Item -Path $(Join-Path $AppFolderTest '*') -Filter "Zepter IT_ZS*.app"
        }
        if ($branch -eq 'master')
        {
            Remove-Item -Path $(Join-Path $AppFolderLive '*') -Filter "Zepter IT_ZS*.app"
        }
        $ClearFolder = $true
    }
    $AppFolder = $AppFolderTest
    if ($branch -eq 'master')
    {
        $AppFolder = $AppFolderLive
    }
    $AppJson = Get-ObjectFromJSON (Join-Path $Target "app.json")
    $ExtensionApp = $(Join-Path $AppFolder $("$($AppJson.publisher)$('_')$($AppJson.name)$('_')$($AppJson.version)$('.app')"))

    $paramProject = '/project:"'+$Target+'"'
    $paramOut     = '/out:"'+$ExtensionApp+'"'
    $paramSymbol  = '/packagecachepath:"'+$(Join-Path $Target $SymbolFolder)+'"'
    $paramError   = '/errorlog:"'+$(Join-Path $Target 'error.log')+'"'

    #write-Host '===Target'
    write-Host $Target -ForegroundColor yellow
    #write-Host '===compilator'
    #write-Host $compilator.fullname
    #write-Host '===Project'
    #write-Host $paramProject 
    #write-Host '===Symbol'
    #write-Host $paramSymbol 
    #write-Host '===Error'
    #write-Host $paramError 
    #write-Host '===Rules'
    #write-Host $paramRules
    #write-Host '===Out'
    #write-Host $paramOut
    #write-Host '===Analyzer'
    #write-Host $paramAnalyzer
    #write-Host '===ProbingPaths'
    #write-Host $assemblyProbingPaths
    #write-Host '==='

    write-Host ''
    write-Host '>>> START Compiling' -ForegroundColor green
    #write-Host "$compilator.fullname $paramProject $paramOut $paramSymbol $paramError $paramAnayzer $assemblyProbingPaths $paramNoWarn /loglevel:Verbose"
    & $compilator.fullname $paramProject $paramOut $paramSymbol $paramError $paramAnayzer $assemblyProbingPaths $paramNoWarn /loglevel:Verbose | Write-Verbose

    $AppFile = Get-ChildItem -path $ExtensionApp
    if ($AppFile) {
        Write-Host "Successfully compiled $ExtensionApp" -ForegroundColor Green
    }
    else {
        write-error "Compilation ended with errors"
    }

    write-Host '>>> END Compiling' -ForegroundColor green
    write-Host ''
}
Set-Location $currentPath
