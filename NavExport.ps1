Import-Module 'c:\Program Files (x86)\Microsoft Dynamics 365 Business Central\140\RoleTailored Client\Microsoft.Dynamics.Nav.Ide.psm1'
Import-Module 'c:\Nav\EXPORT.PTM.BC14\NavFindInTextFile.ps1'

$WorkPath = "c:\Nav\EXPORT.PTM.BC14"
$ServerName = "PLDSQLNAV"
$DatabaseName = "NAV_PLATF_DEV_140"
$HUDatabaseName = "NAV_ZHU_DEV_140"
$ITDatabaseName = "NAV_ITA_DEV_140"

Export-NAVApplicationObject `
-DatabaseServer $ServerName `
-DatabaseName $DatabaseName `
-Path (Join-Path $WorkPath "BC14-PTM.TXT") `
-ExportToNEwSyntax `
-Filter 'Id=<2000000000' `
-Force `
-verbose

Set-Location -Path $WorkPath
Remove-Item -Path (Join-Path $WorkPath "export2al") -Recurse
New-Item -Path $WorkPath -Name "export2al" -ItemType "directory"
New-Item -Path (Join-Path $WorkPath "export2al") -Name "baseapplication" -ItemType "directory"
New-Item -Path (Join-Path $WorkPath "export2al") -Name "dotnet" -ItemType "directory"
New-Item -Path (Join-Path $WorkPath "export2al") -Name "testlibrary" -ItemType "directory"
New-Item -Path (Join-Path $WorkPath "export2al") -Name "zeptersoft" -ItemType "directory"
New-Item -Path (Join-Path $WorkPath "export2al") -Name "zs-it" -ItemType "directory"
New-Item -Path (Join-Path $WorkPath "export2al") -Name "zs-migration" -ItemType "directory"
New-Item -Path (Join-Path $WorkPath "export2al") -Name "zs-tool" -ItemType "directory"

if (Test-Path "baseapplication") { Remove-Item -Path "baseapplication" -Recurse | Out-null }
if (Test-Path "testlibrary")     { Remove-Item -Path "testlibrary" -Recurse | Out-null }
if (Test-Path "zeptersoft")      { Remove-Item -Path "zeptersoft" -Recurse | Out-null }
if (Test-Path "zs-it")           { Remove-Item -Path "zs-it" -Recurse | Out-null }
if (Test-Path "zs-migration")    { Remove-Item -Path "zs-migration" -Recurse | Out-null }
if (Test-Path "zs-tool")         { Remove-Item -Path "zs-tool" -Recurse | Out-null }

$WorkSubPath = (Join-Path (Join-Path $WorkPath "export2al") "baseapplication")
Export-NAVApplicationObject `
-DatabaseServer $ServerName `
-DatabaseName $DatabaseName `
-ExportToNewSyntax `
-Path (Join-Path $WorkSubPath "exportedbc14app-part1.txt") `
-Filter 'Id=1..9999;Version List=*ZS*' `
-Force `
-verbose

Export-NAVApplicationObject `
-DatabaseServer $ServerName `
-DatabaseName $DatabaseName `
-ExportToNewSyntax `
-Path (Join-Path $WorkSubPath "exportedbc14app-part2.txt") `
-Filter 'Id=10000..49999;Version List=*ZS*' `
-Force `
-verbose

Export-NAVApplicationObject `
-DatabaseServer $ServerName `
-DatabaseName $DatabaseName `
-ExportToNewSyntax `
-Path (Join-Path $WorkSubPath "exportedbc14app-part3.txt") `
-Filter 'Id=100000..129999;Version List=*ZS*' `
-Force `
-verbose

Export-NAVApplicationObject `
-DatabaseServer $ServerName `
-DatabaseName $DatabaseName `
-Path (Join-Path $WorkSubPath "exportedbc14app-part4.txt") `
-Filter 'Id=140000..20000000;Version List=*ZS*' `
-Force `
-verbose

Export-NAVApplicationObject `
-DatabaseServer $ServerName `
-DatabaseName $DatabaseName `
-Path (Join-Path $WorkSubPath "exportedbc14app-part5.txt") `
-Filter 'Id=20010000..1999999999;Version List=*ZS*' `
-Force `
-verbose

Export-NAVApplicationObject `
-DatabaseServer $ServerName `
-DatabaseName $DatabaseName `
-ExportToNewSyntax `
-Path (Join-Path $WorkSubPath "exportedbc14testobjects.txt") `
-Filter 'Id=130400..130416;Version List=*ZS*' `
-Force `
-verbose


#####################################
# the exported test library objects #
#####################################
$WorkSubPath = (Join-Path (Join-Path $WorkPath "export2al") "testlibrary")

Export-NAVApplicationObject `
-DatabaseServer $ServerName `
-DatabaseName $DatabaseName `
-ExportToNewSyntax `
-Path (Join-Path $WorkSubPath "bc14testlibrary-part1.txt") `
-Filter 'Id=130000..130399' `
-Force `
-verbose

Export-NAVApplicationObject `
-DatabaseServer $ServerName `
-DatabaseName $DatabaseName `
-ExportToNewSyntax `
-Path (Join-Path $WorkSubPath "bc14testlibrary-part2.txt") `
-Filter 'Id=130440..139999' `
-Force `
-verbose

###########################################
# the exported ZepterSoft library objects #
###########################################
$WorkSubPath = (Join-Path (Join-Path $WorkPath "export2al") "zeptersoft")
Export-NAVApplicationObject `
-DatabaseServer $ServerName `
-DatabaseName $DatabaseName `
-Path (Join-Path $WorkSubPath "bc14zeptersoft-part1.txt") `
-Filter 'Id=20000000..20010000' `
-Force `
-verbose

Export-NAVApplicationObject `
-DatabaseServer $ServerName `
-DatabaseName $DatabaseName `
-Path (Join-Path $WorkSubPath "bc14zeptersoft-part2.txt") `
-Filter 'Id=52500..52599' `
-Force `
-verbose

Export-NAVApplicationObject `
-DatabaseServer $ServerName `
-DatabaseName $DatabaseName `
-Path (Join-Path $WorkSubPath "bc14zeptersoft-part3.txt") `
-Filter 'Id=70000' `
-Force `
-verbose

$files = Get-ChildItem -Path $WorkSubPath -Filter '*.txt' -Recurse
foreach ($file in $files) {
	if ($file.Length -gt 0) {
		Find-InTextFile -FilePath $file.FullName
	}
}    

$WorkSubPath = Join-Path (Join-Path $WorkPath "export2al") "zs-migration"
Export-NAVApplicationObject `
-DatabaseServer $ServerName `
-DatabaseName $HUDatabaseName `
-Path (Join-Path $WorkSubPath "bc14zeptersoft-migration.txt") `
-Filter 'Id=60200..60999|64198' `
-Force `
-verbose

Export-NAVApplicationObject `
-DatabaseServer $ServerName `
-DatabaseName $DatabaseName `
-Path (Join-Path $WorkSubPath "bc14zeptersoft-migration-part2.txt") `
-Filter 'Id=64198' `
-Force `
-verbose

$files = Get-ChildItem -Path $WorkSubPath -Filter '*.txt' -Recurse
foreach ($file in $files) {
	if ($file.Length -gt 0) {
		Find-InTextFile -FilePath $file.FullName
	}
}    

$WorkSubPath = Join-Path (Join-Path $WorkPath "export2al") "zs-it"
Export-NAVApplicationObject `
-DatabaseServer $ServerName `
-DatabaseName $ITDatabaseName `
-Path (Join-Path $WorkSubPath "bc14zeptersoft-italy.txt") `
-Filter 'Id=85000..85999' `
-Force `
-verbose

$files = Get-ChildItem -Path $WorkSubPath -Filter '*.txt' -Recurse
foreach ($file in $files) {
	if ($file.Length -gt 0) {
		Find-InTextFile -FilePath $file.FullName
	}
}    

$WorkSubPath = Join-Path (Join-Path $WorkPath "export2al") "zs-tool"
Export-NAVApplicationObject `
-DatabaseServer $ServerName `
-DatabaseName $DatabaseName `
-Path (Join-Path $WorkSubPath "bc14zeptersoft-tool.txt") `
-Filter 'Type=Codeunit;Id=99000..99999' `
-Force `
-verbose

$files = Get-ChildItem -Path $WorkSubPath -Filter '*.txt' -Recurse
foreach ($file in $files) {
	if ($file.Length -gt 0) {
		Find-InTextFile -FilePath $file.FullName
	}
}    


$WorkSubPathSrc = Join-Path (Join-Path $WorkPath "export2al") "baseapplication"
$WorkSubPathTrg = Join-Path $WorkPath "baseapplication"
$WorkSubPathDotnet = Join-Path (Join-Path (Join-Path $WorkPath "export2al") "dotnet") "mydotnet.al"
Start-Process -FilePath "c:\Program Files (x86)\Microsoft Dynamics 365 Business Central\140\RoleTailored Client\txt2al.exe" `
-Wait `
-ArgumentList "--source=$($WorkSubPathSrc) --target=$($WorkSubPathTrg) --injectDotNetAddIns --dotNetAddInsPackage=$($WorkSubPathDotnet) --dotNetTypePrefix=BC --rename --addLegacyTranslationInfo"

$WorkSubPathSrc = Join-Path (Join-Path $WorkPath "export2al") "testlibrary"
$WorkSubPathTrg = Join-Path $WorkPath "testlibrary"
Start-Process -FilePath "c:\Program Files (x86)\Microsoft Dynamics 365 Business Central\140\RoleTailored Client\txt2al.exe" `
-Wait `
-ArgumentList "--source=$($WorkSubPathSrc) --target=$($WorkSubPathTrg) --injectDotNetAddIns --dotNetTypePrefix=BCTest --rename --addLegacyTranslationInfo"

$WorkSubPathSrc = Join-Path (Join-Path $WorkPath "export2al") "zeptersoft"
$WorkSubPathTrg = Join-Path $WorkPath "zeptersoft"
Start-Process -FilePath "c:\Program Files (x86)\Microsoft Dynamics 365 Business Central\140\RoleTailored Client\txt2al.exe" `
-Wait `
-ArgumentList "--source=$($WorkSubPathSrc) --target=$($WorkSubPathTrg) --injectDotNetAddIns --dotNetTypePrefix=ZS --rename --addLegacyTranslationInfo"

$WorkSubPathSrc = Join-Path (Join-Path $WorkPath "export2al") "zs-it"
$WorkSubPathTrg = Join-Path $WorkPath "zs-it"
Start-Process -FilePath "c:\Program Files (x86)\Microsoft Dynamics 365 Business Central\140\RoleTailored Client\txt2al.exe" `
-Wait `
-ArgumentList "--source=$($WorkSubPathSrc) --target=$($WorkSubPathTrg) --injectDotNetAddIns --dotNetTypePrefix=ZS --rename --addLegacyTranslationInfo"

$WorkSubPathSrc = Join-Path (Join-Path $WorkPath "export2al") "zs-migration"
$WorkSubPathTrg = Join-Path $WorkPath "zs-migration"
Start-Process -FilePath "c:\Program Files (x86)\Microsoft Dynamics 365 Business Central\140\RoleTailored Client\txt2al.exe" `
-Wait `
-ArgumentList "--source=$($WorkSubPathSrc) --target=$($WorkSubPathTrg) --injectDotNetAddIns --dotNetTypePrefix=ZS --rename --addLegacyTranslationInfo"

$WorkSubPathSrc = Join-Path (Join-Path $WorkPath "export2al") "zs-test"
$WorkSubPathTrg = Join-Path $WorkPath "zs-test"
Start-Process -FilePath "c:\Program Files (x86)\Microsoft Dynamics 365 Business Central\140\RoleTailored Client\txt2al.exe" `
-Wait `
-ArgumentList "--source=$($WorkSubPathSrc) --target=$($WorkSubPathTrg) --injectDotNetAddIns --dotNetTypePrefix=ZS --rename --addLegacyTranslationInfo"

$WorkSubPathSrc = Join-Path (Join-Path $WorkPath "export2al") "zs-tool"
$WorkSubPathTrg = Join-Path $WorkPath "zs-tool"
Start-Process -FilePath "c:\Program Files (x86)\Microsoft Dynamics 365 Business Central\140\RoleTailored Client\txt2al.exe" `
-Wait `
-ArgumentList "--source=$($WorkSubPathSrc) --target=$($WorkSubPathTrg) --injectDotNetAddIns --dotNetTypePrefix=ZS --rename --addLegacyTranslationInfo"

New-Item -Path (Join-Path $WorkPath "baseapplication") -Name "Table" -ItemType "directory"
New-Item -Path (Join-Path $WorkPath "baseapplication") -Name "Page" -ItemType "directory"
New-Item -Path (Join-Path $WorkPath "baseapplication") -Name "Codeunit" -ItemType "directory"
New-Item -Path (Join-Path $WorkPath "baseapplication") -Name "Report" -ItemType "directory"

$WorkSubPathSrc = Join-Path (Join-Path $WorkPath "baseapplication") "*.Table.al"
$WorkSubPath = Join-Path (Join-Path $WorkPath "baseapplication") "Table"
Move-Item -Path $WorkSubPathSrc -Destination $WorkSubPath

$WorkSubPathSrc = Join-Path (Join-Path $WorkPath "baseapplication") "*.Page.al"
$WorkSubPath = Join-Path (Join-Path $WorkPath "baseapplication") "Page"
Move-Item -Path $WorkSubPathSrc -Destination $WorkSubPath

$WorkSubPathSrc = Join-Path (Join-Path $WorkPath "baseapplication") "*.Codeunit.al"
$WorkSubPath = Join-Path (Join-Path $WorkPath "baseapplication") "Codeunit"
Move-Item -Path $WorkSubPathSrc -Destination $WorkSubPath

$WorkSubPathSrc = Join-Path (Join-Path $WorkPath "baseapplication") "*.Report.al"
$WorkSubPath = Join-Path (Join-Path $WorkPath "baseapplication") "Report"
Move-Item -Path $WorkSubPathSrc -Destination $WorkSubPath

New-Item -Path (Join-Path $WorkPath "zeptersoft") -Name "Table" -ItemType "directory"
New-Item -Path (Join-Path $WorkPath "zeptersoft") -Name "Page" -ItemType "directory"
New-Item -Path (Join-Path $WorkPath "zeptersoft") -Name "Codeunit" -ItemType "directory"
New-Item -Path (Join-Path $WorkPath "zeptersoft") -Name "Report" -ItemType "directory"
New-Item -Path (Join-Path $WorkPath "zeptersoft") -Name "XmlPort" -ItemType "directory"

$WorkSubPathSrc = Join-Path (Join-Path $WorkPath "zeptersoft") "*.Table.al"
$WorkSubPath = Join-Path (Join-Path $WorkPath "zeptersoft") "Table"
Move-Item -Path $WorkSubPathSrc -Destination $WorkSubPath

$WorkSubPathSrc = Join-Path (Join-Path $WorkPath "zeptersoft") "*.Page.al"
$WorkSubPath = Join-Path (Join-Path $WorkPath "zeptersoft") "Page"
Move-Item -Path $WorkSubPathSrc -Destination $WorkSubPath

$WorkSubPathSrc = Join-Path (Join-Path $WorkPath "zeptersoft") "*.Codeunit.al"
$WorkSubPath = Join-Path (Join-Path $WorkPath "zeptersoft") "Codeunit"
Move-Item -Path $WorkSubPathSrc -Destination $WorkSubPath

$WorkSubPathSrc = Join-Path (Join-Path $WorkPath "zeptersoft") "*.Report.al"
$WorkSubPath = Join-Path (Join-Path $WorkPath "zeptersoft") "Report"
Move-Item -Path $WorkSubPathSrc -Destination $WorkSubPath

$WorkSubPathSrc = Join-Path (Join-Path $WorkPath "zeptersoft") "*.rdlc"
$WorkSubPath = Join-Path (Join-Path $WorkPath "zeptersoft") "Report"
Move-Item -Path $WorkSubPathSrc -Destination $WorkSubPath

$WorkSubPathSrc = Join-Path (Join-Path $WorkPath "zeptersoft") "*.XmlPort.al"
$WorkSubPath = Join-Path (Join-Path $WorkPath "zeptersoft") "XmlPort"
Move-Item -Path $WorkSubPathSrc -Destination $WorkSubPath

