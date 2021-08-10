Write-Host "Deploy SSIS Package" -foregroundcolor green
$sqlInstance="localhost",
$sourceCodeDirPath="c:\User\NPatel\Projects\MySSIS"
$projFilePath = "$sourceCodeDirPath\bin\Development\MySSISProject.ispac"
$projectName = "MySSISProject"
$SSISNamespace = "Microsoft.SqlServer.Management.IntegrationServices"
$SSIDBPassword = "P@assword1"
$targetFolderName = "LoadData_V2"
##------------------
# Load the IntegrationServices Assembly 
$assemblyLoadStatus = [Reflection.Assembly]::LoadWithPartialName($SSISNamespace) 
# Create a connection to the server 
$sqlConnectionString = "Data Source=$sqlInstance;Initial Catalog=master;Integrated Security=SSPI;" 
$sqlConnection = New-Object -TypeName System.Data.SqlClient.SqlConnection -ArgumentList $sqlConnectionString 
# Create the Integration Services object 
$integrationServices = New-Object "$SSISNamespace.IntegrationServices" $sqlConnection
if(!$integrationServices) {
	Write-Host ("Cannot connect to SqlInstance {0}." -f $SqlInstance) -ForegroundColor Yellow
	return
}
# Provision a new SSIS Catalog
$catalog = $integrationServices.Catalogs["SSISDB"]
if(!$catalog){ 
	Write-Host "Creating SSIDB catalog" -foregroundcolor green
	$catalog = New-Object $SSISNamespace".Catalog" ($integrationServices, "SSISDB", $SSIDBPassword)
	$catalog.Create()
}
$targetFolder = $catalog.Folders[$targetFolderName]
if(!$targetFolder)	{
	Write-Host "Create target folder" -foregroundcolor green
	$targetFolder = New-Object $SSISNamespace".CatalogFolder" ($catalog, $targetFolderName, "Folder Description goes here")
	$targetFolder.Create()
}
# Read the project file and deploy it
[byte[]] $projectFile = [System.IO.File]::ReadAllBytes($projFilePath)
$deployStatus = $targetFolder.DeployProject($projectName, $projectFile)
Write-Host "Deployed SSIS Package." -foregroundcolor green
