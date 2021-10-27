﻿<#
Билд для сборки окружения под проекты



prerequsites:
  	Базовые
	!AD domain
	!Set AD users\groups
	!PS 5
	
	
	Дженкинс
	!jenkins node registration
	
	
	
	
	


$IISPools - переменная для создания пулов и сайтов в иис - лист хэштаблиц
    @{
        SiteName = 'AdminMessageApp'  --- ИМЯ САЙТА и ПУЛА
        DomainAuth =  @{ - БЛОК АВТОРИЗАЦИИ ДЛЯ ПУЛА И САЙТА
            userName="$username";password="$pass";identitytype=3
            }
        Bindings= @( -ЛИСТ ДЛЯ Bindings САЙТА.
                @{protocol='https';bindingInformation="*:44307:"}				
                @{protocol='http';bindingInformation="*:8007:"}
                @{protocol='https';bindingInformation="*:13443:vm4apktest-p3.gkbaltbet.local"}
            )		 протокол^  || порт и hostname ^
    }    

#>
$ProgressPreference = 'SilentlyContinue'
## Disable firewall 
Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False
## Disable Wdefender
Set-MpPreference -DisableRealtimeMonitoring $true 
## Allow long path
Set-ItemProperty 'HKLM:\System\CurrentControlSet\Control\FileSystem' -Name 'LongPathsEnabled' -value 1
# iis

[Net.ServicePointManager]::SecurityProtocol = "tls12"
Install-WindowsFeature -name Web-Server -IncludeManagementTools 
Register-PackageSource -Force -provider NuGet -name nugetRepository -location https://www.nuget.org/api/v2
Install-Module  -Force -Name IISAdministration 

### IIS modules
Enable-WindowsOptionalFeature -NoRestart -Online -FeatureName IIS-WebServerRole 
Enable-WindowsOptionalFeature -NoRestart -Online -FeatureName IIS-WebServer
Enable-WindowsOptionalFeature -NoRestart -Online -FeatureName IIS-CommonHttpFeatures
Enable-WindowsOptionalFeature -NoRestart -Online -FeatureName IIS-HttpErrors
Enable-WindowsOptionalFeature -NoRestart -Online -FeatureName IIS-HttpRedirect
Enable-WindowsOptionalFeature -NoRestart -Online -FeatureName IIS-ApplicationDevelopment

Enable-WindowsOptionalFeature -NoRestart -Online -FeatureName NetFx4Extended-ASPNET45
Enable-WindowsOptionalFeature -NoRestart -Online -FeatureName IIS-NetFxExtensibility45

Enable-WindowsOptionalFeature -NoRestart -Online -FeatureName IIS-HealthAndDiagnostics
Enable-WindowsOptionalFeature -NoRestart -Online -FeatureName IIS-HttpLogging
Enable-WindowsOptionalFeature -NoRestart -Online -FeatureName IIS-LoggingLibraries
Enable-WindowsOptionalFeature -NoRestart -Online -FeatureName IIS-RequestMonitor
Enable-WindowsOptionalFeature -NoRestart -Online -FeatureName IIS-HttpTracing
Enable-WindowsOptionalFeature -NoRestart -Online -FeatureName IIS-Security
Enable-WindowsOptionalFeature -NoRestart -Online -FeatureName IIS-RequestFiltering
Enable-WindowsOptionalFeature -NoRestart -Online -FeatureName IIS-Performance
Enable-WindowsOptionalFeature -NoRestart -Online -FeatureName IIS-WebServerManagementTools
Enable-WindowsOptionalFeature -NoRestart -Online -FeatureName IIS-IIS6ManagementCompatibility
Enable-WindowsOptionalFeature -NoRestart -Online -FeatureName IIS-Metabase
Enable-WindowsOptionalFeature -NoRestart -Online -FeatureName IIS-ManagementConsole
Enable-WindowsOptionalFeature -NoRestart -Online -FeatureName IIS-BasicAuthentication
Enable-WindowsOptionalFeature -NoRestart -Online -FeatureName IIS-WindowsAuthentication
Enable-WindowsOptionalFeature -NoRestart -Online -FeatureName IIS-StaticContent
Enable-WindowsOptionalFeature -NoRestart -Online -FeatureName IIS-DefaultDocument
Enable-WindowsOptionalFeature -NoRestart -Online -FeatureName IIS-WebSockets
Enable-WindowsOptionalFeature -NoRestart -Online -FeatureName IIS-ApplicationInit
Enable-WindowsOptionalFeature -NoRestart -Online -FeatureName IIS-ISAPIExtensions
Enable-WindowsOptionalFeature -NoRestart -Online -FeatureName IIS-ISAPIFilter
Enable-WindowsOptionalFeature -NoRestart -Online -FeatureName IIS-HttpCompressionStatic

Enable-WindowsOptionalFeature -NoRestart -Online -FeatureName IIS-ASPNET45 -all

Import-Module -Force WebAdministration
Remove-Website -Name *
Remove-WebAppPool -name *
$username ="GKBALTBET\TestKernel_svc"
$pass = "GldycLIFKM2018"

$RuntimeVersion ='v4.0'

$ProgressPreference = 'SilentlyContinue'
$pathToConfigurationFile = "\\server\tcbuild$\Testers\_VM Update Instructions\Jenkins\mssql19\ConfigurationFile.ini"


<# 
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

 #>

#CHOCOLATEY install
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
# renew env:PATH
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User") 
$ENV:HOMEDRIVE='C:'
$items  = @(
	("notepadplusplus"), ("googlechrome"), ("ssms"), ("git"), ("nuget.commandline"), ("dotnet-sdk"), ("7zip", ""),('powershell-core', ""), 
	("memurai-developer", ""), ("openjdk11", '--params=`"installdir=\java11`"'),
	("rabbitmq",  "--force --version=3.7.17"), ("dotnetcore-3.0-runtime"), ("dotnet-5.0-aspnetruntime", "--version=5.0.6"),
	("dotnet-runtime", "--version=5.0.6"), ("dotnetcore-aspnetruntime", "--version=3.0.3"), ('dotnet-sdk', '--pre'),
	("dotnet-5.0-desktopruntime", "--version=5.0.8"), ("dotnet-runtime", "--version=5.0.8"), 
	("dotnetcore-runtime.install", "--version=3.1.17"), ("dotnetcore", "--version=5.0.6"), 	
	("visualstudio2019buildtools", ''), ("visualstudio2019-workload-netcorebuildtools", ''), 
	("visualstudio2019-workload-visualstudioextensionbuildtools", ''), 
	("visualstudio2019-workload-databuildtools", ''), ("visualstudio2019-workload-nodebuildtools", ''), 
	("visualstudio2019-workload-universalbuildtools", ''), 
	("visualstudio2019-workload-webbuildtools", ''), 
	("graphviz", ''), 
	("nodejs", ''), ("python", ''), ("python2", ''), ("webdeploy", ''), ("urlrewrite", ''),
	("dotnet-5.0-windowshosting", ""), ("dotnetcore-3.0-windowshosting", ''), ("dotnetcore-2.1-windowshosting", '')
)
foreach($i in $items){
	chocolatey install -y  $i
}
npm install --global windows-build-tools


add-LocalGroupMember -Group "Administrators" -Member "jenkins"


# Enable FILESTREAM ! SQL 15
$instance = "MSSQLSERVER"
$wmi = Get-WmiObject -Namespace "ROOT\Microsoft\SqlServer\ComputerManagement15" -Class FilestreamSettings | where {$_.InstanceName -eq $instance}
$wmi.EnableFilestream(3, $instance)
Get-Service -Name $instance | Restart-Service -force

Invoke-Sqlcmd "EXEC sp_configure filestream_access_level, 2"
Invoke-Sqlcmd "RECONFIGURE"

#rabbitmq Fix
SET HOMEDRIVE=C:
Set-Location -Path 'C:\Program Files\RabbitMQ Server\rabbitmq_server-3.7.17\sbin\'
rabbitmq-plugins.bat enable rabbitmq_management
rabbitmq-service.bat stop
rabbitmq-service.bat install
rabbitmq-service.bat start
