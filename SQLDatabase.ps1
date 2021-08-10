$msBuildExe = 'C:\Program Files (x86)\Microsoft Visual Studio\2019\Professional\MSBuild\Current\Bin\MSBuild.exe',
$sourceCodeDirPath="c:\User\NPatel\Projects\MySQLProj"
$myDBName ="Northwind"
$sqlInstance="localhost",
#
Write-Host "Clean & Build MySQLProj.sqlproj Project" -foregroundcolor green
$projPath="$sourceCodeDirPath\MySQLProj.sqlproj"
& "$($msBuildExe)" "$($projPath)" /t:clean /t:Build /m

Write-Host "Deploy $myDBName database to $sqlInstance" -foregroundcolor green
Publish-DbaDacPackage -SqlInstance $sqlInstance -Database $myDBName -Path $sourceCodeDirPath\bin\Debug\MySQLProj.dacpac 
