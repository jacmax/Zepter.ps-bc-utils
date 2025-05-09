$xmlFile = "d:\DEV-EXT\bc-common\Common - App\Translated.pl-PL.xlf"
$xmlConfig = [System.Xml.XmlDocument](Get-Content $xmlFile)
$group = $xmlConfig.xliff.file.body.group
$orderedGroupCollection = $group.'trans-unit' | Sort-Object -Property source
$group.RemoveAll()
$group.SetAttribute("id", "body")
$counter = 0
$source = ''
$orderedGroupCollection | foreach { 
    if ($source -cne $_.source)
    {
        $counter = $counter + 10
        $_.id = "$counter"
        $group.AppendChild($_)
        $source = $_.source
    } 
} | Out-Null
$xmlConfig.Save($xmlFile)
