function NavExport {
    param (
		[Parameter(Mandatory = $true)]
		[string]$Country,
		[Parameter(Mandatory = $true)]
		[string]$CountryFilter1,
		[Parameter(Mandatory = $true)]
		[string]$CountryFilter2,
		[Parameter(Mandatory = $true)]
		[string]$NavVer,
		[Parameter(Mandatory = $true)]
		[string]$WorkPath,
		[Parameter(Mandatory = $true)]
		[string]$ServerName,
		[Parameter(Mandatory = $true)]
		[string]$DatabaseName,
		[Parameter(Mandatory = $true)]
		[string]$finsql
    )

	$ntAutentication = "1"

	Set-Location -Path $WorkPath
	if (Test-Path "export2al") { Remove-Item -Path "export2al" -Recurse | Out-null }
	if (Test-Path "baseapplication") { Remove-Item -Path "baseapplication" -Recurse | Out-null }
	if (Test-Path "zeptersoft")      { Remove-Item -Path "zeptersoft" -Recurse | Out-null }
	if (Test-Path "zs-$($Country)")  { Remove-Item -Path "zs-$($Country)" -Recurse | Out-null }
	if (Test-Path "zs-tool")         { Remove-Item -Path "zs-tool" -Recurse | Out-null }

	$ExportFile = (Join-Path $WorkPath "$($NavVer)-Z$($Country).txt")
	$ExportLogFile = (Join-Path $WorkPath "$($NavVer)-Z$($Country).ExportLog.txt")
	$ExportFilter = "Id=<18031000|>18033000&<2000000000"
	
	Write-Host $NavVer -ForegroundColor Green
	
	if ($NavVer -eq 'BC14') 
	{
		Export-NAVApplicationObject `
			-DatabaseServer $ServerName `
			-DatabaseName $DatabaseName `
			-Path $ExportFile `
			-ExportToNewSyntax `
			-ExportTxtSkipUnlicensed `
			-Filter $ExportFilter `
			-Force `
			-verbose
	}
	else
	{
		Start-Process -FilePath "$finsql" `
		-Wait `
		-ArgumentList "command=exportobjects, file=$ExportFile, logfile=$ExportLogFile, servername=$ServerName, database=$DatabaseName, filter=$ExportFilter, ntauthentication=$ntAutentication"
	}

	New-Item -Path $WorkPath -Name "export2al" -ItemType "directory" | Out-null
	New-Item -Path (Join-Path $WorkPath "export2al") -Name "baseapplication" -ItemType "directory" | Out-null
	New-Item -Path (Join-Path $WorkPath "export2al") -Name "dotnet" -ItemType "directory" | Out-null
	New-Item -Path (Join-Path $WorkPath "export2al") -Name "zeptersoft" -ItemType "directory" | Out-null
	
	####################
	# BaseAppplication #
	####################
	$WorkSubPath = (Join-Path (Join-Path $WorkPath "export2al") "baseapplication")
	$ExportFile = (Join-Path $WorkSubPath "exportedbc14app-part1.txt")
	$ExportLogFile = (Join-Path $WorkPath "exportedbc14app-part1.ExportLog.txt")
	$ExportFilter = """Id=1..9999;Version List=*$($CountryFilter2)*"""
	if ($NavVer -eq 'BC14') 
	{
		$ExportFilter = "Id=1..9999;Version List=*$($CountryFilter2)*"
		Export-NAVApplicationObject `
			-DatabaseServer $ServerName `
			-DatabaseName $DatabaseName `
			-Path $ExportFile `
			-ExportToNewSyntax `
			-Filter $ExportFilter `
			-Force `
			-verbose
	}
	else
	{
		Start-Process -FilePath $finsql `
		-Wait `
		-ArgumentList "command=exportobjects, file=$ExportFile, logfile=$ExportLogFile, servername=$ServerName, database=$DatabaseName, filter=$ExportFilter, ntauthentication=$ntAutentication"
	}
	
	$ExportFile = (Join-Path $WorkSubPath "exportedbc14app-part2.txt")
	$ExportLogFile = (Join-Path $WorkSubPath "exportedbc14app-part2.ExportLog.txt")
	$ExportFilter = """Id=10000..49999;Version List=*$($CountryFilter2)*"""
	if ($NavVer -eq 'BC14') 
	{
		$ExportFilter = "Id=10000..49999;Version List=*$($CountryFilter2)*"
		Export-NAVApplicationObject `
			-DatabaseServer $ServerName `
			-DatabaseName $DatabaseName `
			-Path $ExportFile `
			-ExportToNewSyntax `
			-Filter $ExportFilter `
			-Force `
			-verbose
	}
	else
	{
		Start-Process -FilePath $finsql `
		-Wait `
		-ArgumentList "command=exportobjects, file=$ExportFile, logfile=$ExportLogFile, servername=$ServerName, database=$DatabaseName, filter=$ExportFilter, ntauthentication=$ntAutentication"
	}
	
	$ExportFile = (Join-Path $WorkSubPath "exportedbc14app-part3.txt")
	$ExportLogFile = (Join-Path $WorkSubPath "exportedbc14app-part3.ExportLog.txt")
	$ExportFilter = """Id=100000..129999;Version List=*$($CountryFilter2)*"""
	if ($NavVer -eq 'BC14') 
	{
		$ExportFilter = "Id=100000..129999;Version List=*$($CountryFilter2)*"
		Export-NAVApplicationObject `
			-DatabaseServer $ServerName `
			-DatabaseName $DatabaseName `
			-Path $ExportFile `
			-ExportToNewSyntax `
			-Filter $ExportFilter `
			-Force `
			-verbose
	}
	else
	{
		Start-Process -FilePath $finsql `
		-Wait `
		-ArgumentList "command=exportobjects, file=$ExportFile, logfile=$ExportLogFile, servername=$ServerName, database=$DatabaseName, filter=$ExportFilter, ntauthentication=$ntAutentication"
	}
	
	$ExportFile = (Join-Path $WorkSubPath "exportedbc14app-part4.txt")
	$ExportLogFile = (Join-Path $WorkSubPath "exportedbc14app-part4.ExportLog.txt")
	$ExportFilter = """Id=140000..20000000;Version List=*$($CountryFilter2)*"""
	if ($NavVer -eq 'BC14') 
	{
		$ExportFilter = "Id=140000..20000000;Version List=*$($CountryFilter2)*"
		Export-NAVApplicationObject `
			-DatabaseServer $ServerName `
			-DatabaseName $DatabaseName `
			-Path $ExportFile `
			-ExportToNewSyntax `
			-Filter $ExportFilter `
			-Force `
			-verbose
	}
	else
	{
		Start-Process -FilePath $finsql `
		-Wait `
		-ArgumentList "command=exportobjects, file=$ExportFile, logfile=$ExportLogFile, servername=$ServerName, database=$DatabaseName, filter=$ExportFilter, ntauthentication=$ntAutentication"
	}
	
	$ExportFile = (Join-Path $WorkSubPath "exportedbc14app-part5.txt")
	$ExportLogFile = (Join-Path $WorkSubPath "exportedbc14app-part5.ExportLog.txt")
	$ExportFilter = """Id=20010000..1999999999;Version List=*$($CountryFilter2)*"""
	if ($NavVer -eq 'BC14') 
	{
		$ExportFilter = "Id=20010000..1999999999;Version List=*$($CountryFilter2)*"
		Export-NAVApplicationObject `
			-DatabaseServer $ServerName `
			-DatabaseName $DatabaseName `
			-Path $ExportFile `
			-ExportToNewSyntax `
			-Filter $ExportFilter `
			-Force `
			-verbose
	}
	else
	{
		Start-Process -FilePath $finsql `
		-Wait `
		-ArgumentList "command=exportobjects, file=$ExportFile, logfile=$ExportLogFile, servername=$ServerName, database=$DatabaseName, filter=$ExportFilter, ntauthentication=$ntAutentication"
	}
	
	$ExportFile = (Join-Path $WorkSubPath "exportedbc14testobjects.txt")
	$ExportLogFile = (Join-Path $WorkSubPath "exportedbc14testobjects.ExportLog.txt")
	if ($Country -eq 'PTM')
	{
		$ExportFilter = "Id=130400..130416;Version List=*$($CountryFilter2)*"
		Export-NAVApplicationObject `
			-DatabaseServer $ServerName `
			-DatabaseName $DatabaseName `
			-Path $ExportFile `
			-ExportToNewSyntax `
			-Filter $ExportFilter `
			-Force `
			-verbose
	}
	
	$WorkSubPath = (Join-Path (Join-Path $WorkPath "export2al") "baseapplication")
	$files = Get-ChildItem -Path $WorkSubPath -Filter '*.txt' -Recurse
	foreach ($file in $files) {
		if ($file.Length -gt 0) {
			Find-InTextFile -FilePath $file.FullName -SystemBC14 ($NavVer -eq 'BC14')
		}
	}    

	##############
	# ZepterSoft #
	##############
	$WorkSubPath = (Join-Path (Join-Path $WorkPath "export2al") "zeptersoft")
	$ExportFile = (Join-Path $WorkSubPath "bc14zeptersoft-part1.txt")
	$ExportLogFile = (Join-Path $WorkSubPath "bc14zeptersoft-part1.ExportLog.txt")
	$ExportFilter = """Id=20000000..20010000;Version List=*$($CountryFilter2)*"""
	if ($NavVer -eq 'BC14') 
	{
		$ExportFilter = "Id=20000000..20010000;Version List=*$($CountryFilter2)*"
		Export-NAVApplicationObject `
			-DatabaseServer $ServerName `
			-DatabaseName $DatabaseName `
			-Path $ExportFile `
			-ExportToNEwSyntax `
			-Filter $ExportFilter `
			-Force `
			-verbose
	}
	else
	{
		Start-Process -FilePath $finsql `
		-Wait `
		-ArgumentList "command=exportobjects, file=$ExportFile, logfile=$ExportLogFile, servername=$ServerName, database=$DatabaseName, filter=$ExportFilter, ntauthentication=$ntAutentication"
	}
	
	$ExportFile = (Join-Path $WorkSubPath "bc14zeptersoft-part2.txt")
	$ExportLogFile = (Join-Path $WorkSubPath "bc14zeptersoft-part2.ExportLog.txt")
	$ExportFilter = """Id=52500..52599;Version List=*$($CountryFilter2)*"""
	if ($NavVer -eq 'BC14') 
	{
		$ExportFilter = "Id=52500..52599;Version List=*$($CountryFilter2)*"
		Export-NAVApplicationObject `
			-DatabaseServer $ServerName `
			-DatabaseName $DatabaseName `
			-Path $ExportFile `
			-ExportToNEwSyntax `
			-Filter $ExportFilter `
			-Force `
			-verbose
	}
	else
	{
		Start-Process -FilePath $finsql `
		-Wait `
		-ArgumentList "command=exportobjects, file=$ExportFile, logfile=$ExportLogFile, servername=$ServerName, database=$DatabaseName, filter=$ExportFilter, ntauthentication=$ntAutentication"
	}

	if ($Country -eq 'PTM')
	{
		$ExportFile = (Join-Path $WorkSubPath "bc14zeptersoft-part3.txt")
		$ExportLogFile = (Join-Path $WorkSubPath "bc14zeptersoft-part3.ExportLog.txt")
		$ExportFilter = """Id=70000..70010"""
		if ($NavVer = 'BC14') 
		{
			$ExportFilter = "Id=70000..70010"
			Export-NAVApplicationObject `
				-DatabaseServer $ServerName `
				-DatabaseName $DatabaseName `
				-Path $ExportFile `
				-ExportToNEwSyntax `
				-Filter $ExportFilter `
				-Force `
				-verbose
		}
		else
		{
			Start-Process -FilePath $finsql `
			-Wait `
			-ArgumentList "command=exportobjects, file=$ExportFile, logfile=$ExportLogFile, servername=$ServerName, database=$DatabaseName, filter=$ExportFilter, ntauthentication=$ntAutentication"
		}
		
		New-Item -Path (Join-Path $WorkPath "export2al") -Name "zs-tool" -ItemType "directory" | Out-null
		
		$WorkSubPath = (Join-Path (Join-Path $WorkPath "export2al") "zs-tool")
		$ExportFile = (Join-Path $WorkSubPath "bc14zeptersoft-tool.txt")
		$ExportLogFile = (Join-Path $WorkSubPath "bc14zeptersoft-tool.ExportLog.txt")
		$ExportFilter = """Id=99000..99999"""
		if ($NavVer -eq 'BC14') 
		{
			$ExportFilter = "Id=99000..99999"
			Export-NAVApplicationObject `
				-DatabaseServer $ServerName `
				-DatabaseName $DatabaseName `
				-Path $ExportFile `
				-ExportToNEwSyntax `
				-Filter $ExportFilter `
				-Force `
				-verbose
		}
		else
		{
			Start-Process -FilePath $finsql `
			-Wait `
			-ArgumentList "command=exportobjects, file=$ExportFile, logfile=$ExportLogFile, servername=$ServerName, database=$DatabaseName, filter=$ExportFilter, ntauthentication=$ntAutentication"
		}
	}
	
	$WorkSubPath = (Join-Path (Join-Path $WorkPath "export2al") "zeptersoft")
	$files = Get-ChildItem -Path $WorkSubPath -Filter '*.txt' -Recurse
	foreach ($file in $files) {
		if ($file.Length -gt 0) {
			Find-InTextFile -FilePath $file.FullName -SystemBC14 ($NavVer -eq 'BC14')
		}
	}    

	###########
	# Country #
	###########
	if ($Country -ne 'PTM')
	{
		New-Item -Path (Join-Path $WorkPath "export2al") -Name "zs-$($Country)" -ItemType "directory" | Out-null
		
		$WorkSubPath = (Join-Path (Join-Path $WorkPath "export2al") "zs-$($Country)")
		$ExportFile = (Join-Path $WorkSubPath "bc14zeptersoft-$($Country).txt")
		$ExportLogFile = (Join-Path $WorkSubPath "bc14zeptersoft-$($Country).ExportLog.txt")
		$ExportFilter = $CountryFilter1
		if ($NavVer -eq 'BC14') 
		{
			Export-NAVApplicationObject `
				-DatabaseServer $ServerName `
				-DatabaseName $DatabaseName `
				-Path $ExportFile `
				-ExportToNEwSyntax `
				-Filter $ExportFilter `
				-Force `
				-verbose
		}
		else
		{
			Start-Process -FilePath $finsql `
			-Wait `
			-ArgumentList "command=exportobjects, file=$ExportFile, logfile=$ExportLogFile, servername=$ServerName, database=$DatabaseName, filter=$ExportFilter, ntauthentication=$ntAutentication"
		}
		
		$WorkSubPath = (Join-Path (Join-Path $WorkPath "export2al") "zs-$($Country)")
		$files = Get-ChildItem -Path $WorkSubPath -Filter '*.txt' -Recurse
		foreach ($file in $files) {
			if ($file.Length -gt 0) {
				Find-InTextFile -FilePath $file.FullName -SystemBC14 ($NavVer -eq 'BC14')
			}
		}    
	}
	
	$WorkSubPathSrc = Join-Path (Join-Path $WorkPath "export2al") "baseapplication"
	$WorkSubPathTrg = Join-Path $WorkPath "baseapplication"
	$WorkSubPathDotnet = Join-Path (Join-Path (Join-Path $WorkPath "export2al") "dotnet") "mydotnet.al"
	Start-Process -FilePath "c:\Program Files (x86)\Microsoft Dynamics 365 Business Central\140\RoleTailored Client\txt2al.exe" `
	-Wait `
	-ArgumentList "--source=$($WorkSubPathSrc) --target=$($WorkSubPathTrg) --injectDotNetAddIns --dotNetAddInsPackage=$($WorkSubPathDotnet) --dotNetTypePrefix=BC --rename --addLegacyTranslationInfo"
	SortObjectToFolders(Join-Path $WorkPath "baseapplication");

	$WorkSubPathSrc = Join-Path (Join-Path $WorkPath "export2al") "zeptersoft"
	$WorkSubPathTrg = Join-Path $WorkPath "zeptersoft"
	Start-Process -FilePath "c:\Program Files (x86)\Microsoft Dynamics 365 Business Central\140\RoleTailored Client\txt2al.exe" `
	-Wait `
	-ArgumentList "--source=$($WorkSubPathSrc) --target=$($WorkSubPathTrg) --injectDotNetAddIns --dotNetTypePrefix=ZS --rename --addLegacyTranslationInfo"
	SortObjectToFolders(Join-Path $WorkPath "zeptersoft");

	$WorkSubPathSrc = Join-Path (Join-Path $WorkPath "export2al") "zs-$($Country)"
	$WorkSubPathTrg = Join-Path $WorkPath "zs-$($Country)"
	Start-Process -FilePath "c:\Program Files (x86)\Microsoft Dynamics 365 Business Central\140\RoleTailored Client\txt2al.exe" `
	-Wait `
	-ArgumentList "--source=$($WorkSubPathSrc) --target=$($WorkSubPathTrg) --injectDotNetAddIns --dotNetTypePrefix=ZS --rename --addLegacyTranslationInfo"
	SortObjectToFolders(Join-Path $WorkPath "zs-$($Country)");

    $ZipFile = ($WorkPath + '.7z') 
    #$ZipFolder = ($WorkPath + '\*.*')
	$ZipFolder = ($WorkPath)

    Remove-Item $ZipFile -ErrorAction Ignore

    Start-Process `
        -FilePath "C:\Program Files\7-Zip\7z.exe" `
        -ArgumentList "a -t7z -r $ZipFile $ZipFolder"
}

function SortObjectToFolders {
   param (
		[Parameter(Mandatory = $true)]
		[string]$Folder
    )
	
	New-Item -Path $Folder -Name "Table" -ItemType "directory" | Out-null
	New-Item -Path $Folder -Name "Page" -ItemType "directory" | Out-null
	New-Item -Path $Folder -Name "Codeunit" -ItemType "directory" | Out-null
	New-Item -Path $Folder -Name "Report" -ItemType "directory" | Out-null
	New-Item -Path $Folder -Name "XmlPort" -ItemType "directory" | Out-null
	New-Item -Path $Folder -Name "Query" -ItemType "directory" | Out-null

	$WorkSubPathSrc = Join-Path $Folder "*.Table.al"
	$WorkSubPath = Join-Path $Folder "Table"
	Move-Item -Path $WorkSubPathSrc -Destination $WorkSubPath

	$WorkSubPathSrc = Join-Path $Folder "*.Page.al"
	$WorkSubPath = Join-Path $Folder "Page"
	Move-Item -Path $WorkSubPathSrc -Destination $WorkSubPath

	$WorkSubPathSrc = Join-Path $Folder "*.Codeunit.al"
	$WorkSubPath = Join-Path $Folder "Codeunit"
	Move-Item -Path $WorkSubPathSrc -Destination $WorkSubPath

	$WorkSubPathSrc = Join-Path $Folder "*.Report.al"
	$WorkSubPath = Join-Path $Folder "Report"
	Move-Item -Path $WorkSubPathSrc -Destination $WorkSubPath

	$WorkSubPathSrc = Join-Path $Folder "*.rdlc"
	$WorkSubPath = Join-Path $Folder "Report"
	Move-Item -Path $WorkSubPathSrc -Destination $WorkSubPath

	$WorkSubPathSrc = Join-Path $Folder "*.XmlPort.al"
	$WorkSubPath = Join-Path $Folder "XmlPort"
	Move-Item -Path $WorkSubPathSrc -Destination $WorkSubPath

	$WorkSubPathSrc = Join-Path $Folder "*.Query.al"
	$WorkSubPath = Join-Path $Folder "Query"
	Move-Item -Path $WorkSubPathSrc -Destination $WorkSubPath
}
