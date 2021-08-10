Import-Module 'c:\Nav\NavTables.ps1'
Import-Module 'c:\Nav\NavCodeunits.ps1'

function Find-InTextFile {
    <#
    .SYNOPSIS
        Performs a find (or replace) on a string in a text file or files.
    .EXAMPLE
        PS> Find-InTextFile -FilePath 'C:\MyFile.txt'
    
    .PARAMETER FilePath
        The file path of the text file you'd like to perform a find/replace on.
    .PARAMETER NewFilePath
        If a new file with the replaced the string needs to be created instead of replacing
        the contents of the existing file use this param to create a new file.
    .PARAMETER Force
        If the NewFilePath param is used using this param will overwrite any file that
        exists in NewFilePath.
    #>
    [CmdletBinding(DefaultParameterSetName = 'NewFile')]
    [OutputType()]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateScript({Test-Path -Path $_ -PathType 'Leaf'})]
        [string[]]$FilePath,
        [Parameter(ParameterSetName = 'NewFile')]
        [ValidateScript({ Test-Path -Path ($_ | Split-Path -Parent) -PathType 'Container' })]
        [string]$NewFilePath,
        [Parameter(ParameterSetName = 'NewFile')]
        [switch]$Force
    )
    begin {
        $Find = [regex]::Escape($Find)
    }
    process {
        try {
			$tables = GetNavTables
			$codeunits = GetNavCodeunits
            foreach ($File in $FilePath) {
                if ($NewFilePath) {
                    if ((Test-Path -Path $NewFilePath -PathType 'Leaf') -and $Force.IsPresent) {
                        Remove-Item -Path $NewFilePath -Force
                        $string = Get-Content $File
                        foreach ($table in $Tables) {
                            Write-Host $table[0]
                            $string = $string.replace($table[0],$table[1])
                        }
                        $string | Add-Content -Path $NewFilePath -Force
                    } elseif ((Test-Path -Path $NewFilePath -PathType 'Leaf') -and !$Force.IsPresent) {
                        Write-Warning "The file at '$NewFilePath' already exists and the -Force param was not used"
                    } else {
                        #(Get-Content $File) -replace $Find, $Replace | Add-Content -Path $NewFilePath -Force
                        $string = Get-Content $File
                        foreach ($table in $Tables) {
                            Write-Host $table[0]
                            $string = $string.replace($table[0],$table[1])
                        }
                        $string | Add-Content -Path $NewFilePath -Force
                    }
                } else {
                    #(Get-Content $File) -replace $Find, $Replace | Add-Content -Path "$File.tmp" -Force
                    $string = (Get-Content $File)
                    $i = 0
                    foreach ($table in $Tables) {
                        $i = $i + 1
                        Write-Progress -Activity "Updating record names" -Status "Progress:" -PercentComplete ($i/$Tables.count*100)
                        $string = $string.replace($table[0],$table[1])
                    }
                    $i = 0
                    foreach ($codeunit in $Codeunits) {
                        $i = $i + 1
                        Write-Progress -Activity "Updating codeunit names" -Status "Progress:" -PercentComplete ($i/$Codeunits.count*100)
                        $string = $string.replace($codeunit[0],$codeunit[1])
                    }
                    $string | Add-Content -Path "$File.tmp" -Force
                    Remove-Item -Path $File
                    Move-Item -Path "$File.tmp" -Destination $File
                }
            }
        } catch {
            Write-Error $_.Exception.Message
        }
    }
}