﻿<#
Билд для сборки окружения под проекты



prerequsites:
  	Базовые
	!AD domain
	!Set AD users\groups
	!PS 5
	
	
	Дженкинс
	!java 11
	!jenkins node registration
	
	
	Дополнительно
	~npp++
	~chrome
	
	
	


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

:TODO 

пока не реализованы:
sslFlags 
Подстановка сертификатов

#>
## Disable firewall 
Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False
## Disable Wdefender
Set-MpPreference -DisableRealtimeMonitoring $true 
# iis

[Net.ServicePointManager]::SecurityProtocol = "tls12"
Install-WindowsFeature -name Web-Server -IncludeManagementTools 
Register-PackageSource -provider NuGet -name nugetRepository -location https://www.nuget.org/api/v2
Install-Module  -Force -Name IISAdministration 

Import-Module WebAdministration
Remove-Website -Name *
Remove-WebAppPool -name *
$username ="GKBALTBET\TestKernel_svc"
$pass = "GldycLIFKM2018"

$IISPools = @( 
    @{
        SiteName = 'AdminMessageApp'
        DomainAuth =  @{
            userName="$username";password="$pass";identitytype=3
            }
        Bindings= @(
                @{protocol='https';bindingInformation="*:44307:"}
            )
    }    
    @{
        SiteName = 'auth_aouth'
        DomainAuth =  @{
            userName="$username";password="$pass";identitytype=3
            }        
        Bindings= @(
                @{protocol='https';bindingInformation="*:449:"}
            )
    }    
    @{
        SiteName = 'baltbetcom'
        DomainAuth =  @{
            userName="$username";password="$pass";identitytype=3
            }
        Bindings= @(
                @{protocol='http';bindingInformation="*:84:"}
                @{protocol='https';;bindingInformation="*:4444:"}
            )
    }    
    @{
        SiteName = 'baltbetru'
        DomainAuth =  @{
            userName="$username";password="$pass";identitytype=3
            }
        Bindings= @(
                @{protocol='http';bindingInformation="*:81:"}
                @{protocol='https';;bindingInformation="*:4445:"}
            )
    }
    @{
        SiteName = 'baltplaymobile'
        DomainAuth =  @{
            userName="$username";password="$pass";identitytype=3
            }
        Bindings= @(
                @{protocol='http';bindingInformation="*:82:"}
                @{protocol='https';;bindingInformation="*:4447:"}
            )
    }
    @{
        SiteName = 'ClientWorkSpace'
        DomainAuth =  @{
            userName="$username";password="$pass";identitytype=3
            }
        Bindings= @(
                @{protocol='http';bindingInformation="*:8080:"}
            )
    }
    @{
        SiteName = 'images'
        DomainAuth =  @{
            userName="$username";password="$pass";identitytype=3
            }
        Bindings= @(
                @{protocol='https';bindingInformation="*:443:"}
            )
    }
    @{
        SiteName = 'Mobile'
        DomainAuth =  @{
            userName="$username";password="$pass";identitytype=3
            }
        Bindings= @(
                @{protocol='http';bindingInformation="*:83:"}
                @{protocol='https';bindingInformation="*:446:"}
            )
    }
    @{
        SiteName = 'paysys'
        DomainAuth =  @{
            userName="$username";password="$pass";identitytype=3
            }
        Port = 88
        proto = "http"
        Header = ""
        Bindings= @(
                @{protocol='http';bindingInformation="*:88:"}
            )
    }
    @{
        SiteName = 'TimeBookingHost'
        DomainAuth =  @{
            userName="$username";password="$pass";identitytype=3
            }
        Bindings= @(
                @{protocol='http';bindingInformation="*:63298:"}
            )
    }    
    @{
        SiteName = 'UniRu'
        DomainAuth =  @{
            userName="$username";password="$pass";identitytype=3
            }
        Bindings= @(
                @{protocol='https';bindingInformation="*:4443:"}
            )
    }    
    @{
        SiteName = 'UniRuWebApi'
        DomainAuth =  @{
            userName="$username";password="$pass";identitytype=3
            }
        Bindings= @(
                @{protocol='https';bindingInformation="*:4449:"}
            )
    }
)  
$RuntimeVersion ='v4.0'
foreach($site in $IISPools ){
    $name =  $site.SiteName
    New-Item –Path IIS:\AppPools\$name -force
    Set-ItemProperty –Path IIS:\AppPools\$name -Name managedRuntimeVersion -Value 'v4.0'
    Set-ItemProperty –Path IIS:\AppPools\$name -Name startMode -Value 'AlwaysRunning'
    if ($site.DomainAuth){
       Set-ItemProperty IIS:\AppPools\$name -name processModel -value $site.DomainAuth
    }
    Start-WebAppPool -Name $name
    New-Website -Name "$name" -ApplicationPool "$name" -PhysicalPath "c:\inetpub\$name" -Force
    $IISSite = "IIS:\Sites\$name"
    Set-ItemProperty $IISSite -name  Bindings -value $site.Bindings
    Start-WebSite -Name "$name"
}


##mssql


$isoLocation = "\\server\Soft\Microsoft\ISO\SQL 2019 Enterprice\en_sql_server_2019_enterprise_x64_dvd_c7d70add.iso"
$pathToConfigurationFile = "\\server\tcbuild$\Testers\_VM Update Instructions\Jenkins\mssql19\ConfigurationFile.ini"
$copyFileLocation = "C:\Temp\ConfigurationFile.ini"
$errorOutputFile = "C:\Temp\ErrorOutput.txt"
$standardOutputFile = "C:\Temp\StandardOutput.txt"

Write-Host "Copying the ini file."

New-Item "C:\Temp" -ItemType "Directory" -Force
Remove-Item $errorOutputFile -Force
Remove-Item $standardOutputFile -Force
Copy-Item $pathToConfigurationFile $copyFileLocation -Force

Write-Host "Getting the name of the current user to replace in the copy ini file."
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

Write-Host "If no red text then SQL Server Successfully Installed!"


##ssms
# Set file and folder path for SSMS installer .exe
$folderpath="c:\windows\temp"
$filepath="$folderpath\SSMS-Setup-ENU.exe"
 
#If SSMS not present, download
if (!(Test-Path $filepath)){
write-host "Downloading SQL Server 2016 SSMS..."
$URL = "https://aka.ms/ssmsfullsetup"
$clnt = New-Object System.Net.WebClient
$clnt.DownloadFile($url,$filepath)
Write-Host "SSMS installer download complete" -ForegroundColor Green
 
}
else {
 
write-host "Located the SQL SSMS Installer binaries, moving on to install..."
}
 
# start the SSMS installer
write-host "Beginning SSMS 2016 install..." -nonewline
$Parms = " /Install /Quiet /Norestart /Logs log.txt"
$Prms = $Parms.Split(" ")
& "$filepath" $Prms | Out-Null
Write-Host "SSMS installation complete" -ForegroundColor Green

remove-item $filepath