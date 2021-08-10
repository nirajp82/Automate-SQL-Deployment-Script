$sourceCodeDirPath="c:\User\NPatel\Projects\MySSIS"
$projectName = "MySSISProject"
$dtProjFolderToLoad = "$sourceCodeDirPath\dataload\$projectName"
$dtProjFileToLoad = Join-Path $dtProjFolderToLoad "$projectName.dtproj"
$ispacFolder = "$dtProjFolderToLoad\bin\CustomRelease\$projectName"
#
[xml]$dtProjXmlDoc = New-Object System.Xml.XmlDocument
$dtProjXmlDoc.PreserveWhitespace = $true
$dtProjXmlDoc.Load($dtProjFileToLoad)
# Create folder with the project name. This will essentially be zipped into an ispac
New-Item -ItemType Directory -Force -Path $ispacFolder

# Create the project manifest in the ispac folder
# Exists in node /Project/DeploymentModelSpecificContent/Manifest/SSIS:Project
$projectManifestXml = $dtProjXmlDoc.Project.DeploymentModelSpecificContent.Manifest.Project.OuterXml
$projectManifestFullPath = Join-Path $ispacFolder "@Project.manifest"
$projectManifestXml | Out-File $projectManifestFullPath -NoNewline

# Add [Content types].xml, which has a static content
$contentTypesXml = "<?xml version=`"1.0`" encoding=`"utf-8`"?><Types xmlns=`"http://schemas.openxmlformats.org/package/2006/content-types`"><Default Extension=`"dtsx`" ContentType=`"text/xml`" /><Default Extension=`"conmgr`" ContentType=`"text/xml`" /><Default Extension=`"params`" ContentType=`"text/xml`" /><Default Extension=`"manifest`" ContentType=`"text/xml`" /></Types>"
$contentTypesFullPath = Join-Path $ispacFolder '[Content_Types].xml'
$contentTypesXml | Out-File -LiteralPath $contentTypesFullPath -NoNewline -Encoding "UTF8"

# Iterate over all SSIS packages (*.dtsx) inside the .dtproj file add them to the ispac folder
$dtProjXmlDoc.Project.DeploymentModelSpecificContent.Manifest.Project.Packages.Package | ForEach-Object { 
    $fileToCopy = (Join-Path $dtProjFolderToLoad ([string]$_.Name))
    Copy-Item $fileToCopy $ispacFolder 
}

# Iterate over all project-level connection managers (*.connmgr), add them to the ispac folder
$dtProjXmlDoc.Project.DeploymentModelSpecificContent.Manifest.Project.ConnectionManagers.ConnectionManager | ForEach-Object { 
    $fileToCopy = (Join-Path $dtProjFolderToLoad ([string]$_.Name))
    Copy-Item $fileToCopy $ispacFolder 
}

# Copy the parameters file to the ispac folder
$paramsFullPathSource = Join-Path $dtProjFolderToLoad "Project.params"
Copy-Item $paramsFullPathSource $ispacFolder

# Archive the ispac folder as a ".ispac" file
Compress-Archive ($ispacFolder + "\*") ($ispacFolder + ".zip") -Force
Rename-Item ($ispacFolder + ".zip") ($ispacFolder + ".ispac") -Force
#Remove-Item $ispacFolder -Recurse -Force
