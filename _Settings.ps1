$Workspace = 'C:\DEVELOPER'
$AppFolder = 'C:\DEVELOPER\APP\'

$SymbolFolder = '.alpackages'

$AppJsons = Get-ChildItem $Workspace -Recurse 'app.json' | where{$_.PSParentPath -like "*App*"}

$TargetRepos = (Get-ChildItem $Workspace -Recurse -Hidden -Include '.git').Parent.FullName
$Targets = $AppJsons.directory.fullname
