$containerName14 = 'zs-bc140'
$SourceFolder = 'd:\EXPORT\EXPORT.PTM.BC14.oldsyntax\export2al\baseapplication\'

$SourceFile = 'exportedbc14app-part1.txt'
Import-ObjectsToNavContainer `
    -containerName $containerName14 `
    -objectsFile (Join-Path $SourceFolder $SourceFile)

$SourceFile = 'exportedbc14app-part5.txt'
Import-ObjectsToNavContainer `
    -containerName $containerName14 `
    -objectsFile (Join-Path $SourceFolder $SourceFile)

$SourceFolder = 'd:\EXPORT\EXPORT.PTM.BC14.oldsyntax\export2al\zeptersoft\'

$SourceFile = 'bc14zeptersoft-part1.txt'
Import-ObjectsToNavContainer `
    -containerName $containerName14 `
    -objectsFile (Join-Path $SourceFolder $SourceFile)

$SourceFile = 'bc14zeptersoft-part2.txt'
Import-ObjectsToNavContainer `
    -containerName $containerName14 `
    -objectsFile (Join-Path $SourceFolder $SourceFile)

$SourceFile = 'bc14zeptersoft-part3.txt'
Import-ObjectsToNavContainer `
    -containerName $containerName14 `
    -objectsFile (Join-Path $SourceFolder $SourceFile)

Compile-ObjectsInNavContainer `
    -containerName $containerName14 `
    -SynchronizeSchemaChanges Yes

#$SourceFolder = 'c:\programdata\bccontainerhelper\objects'
#$SourceFile = 'tab9.txt'

#Export-NavContainerObjects `
#    -containerName $containerName14 `
#    -objectsFolder $SourceFolder `
#    -exportTo 'txt folder' `
#    -filter 'modified=No;ID=9'


