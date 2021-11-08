$RuntimeVersion ='v4.0'

Add-LocalGroupMember -Group "Administrators" -Member "GKBALTBET\test.gkbaltbet.local-DomainAdmins" ,"GKBALTBET\jenkins"

$ProgressPreference = 'SilentlyContinue'
$pathToConfigurationFile = "\\server\tcbuild$\Testers\_VM Update Instructions\Jenkins\mssql19\ConfigurationFile.ini"

 
$isoLocation = "\\server\Soft\Microsoft\ISO\SQL 2019 Enterprice\en_sql_server_2019_enterprise_x64_dvd_c7d70add.iso"
$copyFileLocation = "C:\Temp\ConfigurationFile.ini"
$errorOutputFile = "C:\Temp\ErrorOutput.txt"
$standardOutputFile = "C:\Temp\StandardOutput.txt"
Write-Host "Copying the ini file."

New-Item "C:\Temp" -ItemType "Directory" -Force
Remove-Item $errorOutputFile -Force
Remove-Item $standardOutputFile -Force
Copy-Item $pathToConfigurationFile $copyFileLocation -Force
# legacy mssql server statement
#$user = "$env:UserDomain\$env:USERNAME"

#write-host $user
##
#Write-Host "Replacing the placeholder user name with your username"
#$replaceText = (Get-Content -path $copyFileLocation -Raw) -replace "##MyUser##", $user
#Set-Content $copyFileLocation $replaceText

Write-Host "Mounting SQL Server Image"
$drive = Mount-DiskImage -ImagePath $isoLocation

Write-Host "Getting Disk drive of the mounted image"
$disks = Get-WmiObject -Class Win32_logicaldisk -Filter "DriveType = '5'"

foreach ($disk in $disks){
 $driveLetter = $disk.DeviceID
}

if ($driveLetter)
{
 Write-Host "Starting the install of SQL Server"
Start-Process $driveLetter\Setup.exe "/ConfigurationFile=$copyFileLocation  /IAcceptSQLServerLicenseTerms" -Wait -RedirectStandardOutput $standardOutputFile -RedirectStandardError $errorOutputFile
}
$standardOutput = Get-Content $standardOutputFile -Delimiter "\r\n"

Write-Host $standardOutput

$errorOutput = Get-Content $errorOutputFile -Delimiter "\r\n"

Write-Host $errorOutput

Write-Host "Dismounting the drive."

Dismount-DiskImage -InputObject $drive

Remove-Item "c:\temp" -Recurse -force

$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User") 
# Enable FILESTREAM ! SQL 15
$instance = "MSSQLSERVER"
$wmi = Get-WmiObject -Namespace "ROOT\Microsoft\SqlServer\ComputerManagement15" -Class FilestreamSettings | where {$_.InstanceName -eq $instance}
$wmi.EnableFilestream(3, $instance)
Get-Service -Name $instance | Restart-Service -force

Invoke-Sqlcmd "EXEC sp_configure filestream_access_level, 2"
Invoke-Sqlcmd "RECONFIGURE"