<#
Билд для сборки окружения под проекты



prerequsites:
  	Базовые
	!AD domain
	!Set AD users\groups
	!PS 5
	
	
	Дженкинс
	!jenkins node registration
	
	
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
$RuntimeVersion ='v4.0'



#CHOCOLATEY install
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
# renew env:PATH
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User") 
$items  = @(
	("notepadplusplus"), ("googlechrome"), ("ssms"), ("git"), ("nuget.commandline"), ("dotnet-sdk"), ("7zip", ""),('powershell-core', ""), 
	("memurai-developer", ""), ("openjdk11", ' --version=11.0.12.7'),
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
	$ENV:HOMEDRIVE='C:'
	chocolatey install -y  $i
}
npm install --global windows-build-tools


add-LocalGroupMember -Group "Administrators" -Member "jenkins"

<# 

#rabbitmq Fix
SET HOMEDRIVE=C:
Set-Location -Path 'C:\Program Files\RabbitMQ Server\rabbitmq_server-3.7.17\sbin\'
rabbitmq-plugins.bat enable rabbitmq_management
rabbitmq-service.bat stop
rabbitmq-service.bat install
rabbitmq-service.bat start
 #>