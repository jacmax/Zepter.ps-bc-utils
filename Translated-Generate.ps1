$includedXML = ''
$xmlFileArray =
"d:\DEV-EXT\bc-common\Common - App\Translations\ZS Common.g.pl-PL.xlf",
"d:\DEV-EXT\bc-sales-items\Sales Items - App\Translations\ZS Sales Item.g.pl-PL.xlf",
"d:\DEV-EXT\bc-representatives\Representatives - App\Translations\ZS Representative.g.pl-PL.xlf",
"d:\DEV-EXT\bc-sales-contracts\Sales Contracts - App\Translations\ZS Sales Contract.g.pl-PL.xlf",
"d:\DEV-EXT\bc-payments\Payments - App\Translations\ZS Payment.g.pl-PL.xlf",
"d:\DEV-EXT\bc-commissions\Commission - App\Translations\ZS Commission.g.pl-PL.xlf",
"d:\DEV-EXT\bc-personal-vouchers\Personal Vouchers - App\Translations\ZS Personal Voucher.g.pl-PL.xlf",
"d:\DEV-EXT\bc-integration-pl\Integration PL - App\Translations\ZS Integration PL.g.pl-PL.xlf"

$xmlFileSources = "d:\DEV-EXT\bc-common\Common - App\Translated.sources.pl-PL.xlf"
$fileExits = Test-Path -Path $xmlFileSources
if ($fileExits) {
    $xmlSources = [Xml] (Get-Content $xmlFileSources)
    $groupSources = $xmlSources.xliff.file.body.group

    $groupSources.RemoveAll()
    $groupSources.SetAttribute("id", "body")

    $xmlSources.Save($xmlFileSources)
}
else {
    Write-Host "File $xmlFileSources not found"
}

foreach ($xmlFile in $xmlFileArray) {
    $xmlExport = [Xml] (Get-Content $xmlFile)
    $xmlExport.xliff.file.body.group.'trans-unit' | ForEach-Object {
        try {
            $groupSources.AppendChild($xmlSources.ImportNode($_, $true))
        }
        catch {
            <#Do this if a terminating exception happens#>
            Write-Host $xmlFile $_
            Write-Host $_.InnerXml $_.OuterXml
            exit
        }
    } | Out-Null
}

$orderedGroupCollection = $groupSources.'trans-unit' | Sort-Object -Property source
$groupSources.RemoveAll()
$groupSources.SetAttribute("id", "body")
$source = ''
$orderedGroupCollection | ForEach-Object {
    if ($source -cne $_.source) {
        $_.SetAttribute("id", "")
        $_.RemoveAttribute("translate")
        $_.RemoveAttribute("xml:space")
        if (($_.target)) {
            $_.target.SetAttribute("state", "translated")
            $_.target.RemoveAttribute("state-qualifier")
        }
        $note1 = $_.note[0]
        $note2 = $_.note[1]
        $note1.ParentNode.RemoveChild($note1)
        $note2.ParentNode.RemoveChild($note2)
        if ($includedXML) {
            if ($_.target.InnerXML -match $includedXML) {
                $groupSources.AppendChild($_)
            }
        }
        else {
            $groupSources.AppendChild($_)
        }

        $source = $_.source
    }
} | Out-Null

$xmlSources.Save($xmlFileSources)

(Get-Content $xmlFileSources) | Where-Object { $_.trim() -ne "" } | Set-Content $xmlFileSources -Encoding UTF8
