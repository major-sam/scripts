<#
Скрипт для равертывания нового релиза 03-09-2021
powershell.exe -file "\\server\tcbuild$\Testers\_VM Update Instructions\03.09.2021 RELEASE\03.09.2021 RELEASE.ps1"


Удаленный запуск:
у себя в Powershell
Invoke-Command -FilePath '\\server\tcbuild$\Testers\_VM Update Instructions\03.09.2021 RELEASE\03.09.2021 RELEASE.ps1' -ComputerName <ИМЯ_ПК>

Пример:
Invoke-Command -FilePath '\\server\tcbuild$\Testers\_VM Update Instructions\03.09.2021 RELEASE\03.09.2021 RELEASE.ps1' -ComputerName  VM-HM1-WS2 


Проверка: +79112492620 Qwerty1z
#>
$ProgressPreference = 'SilentlyContinue'
$release_folder = "\\server\tcbuild$\Testers\_VM Update Instructions\03.09.2021 RELEASE"
$release_bak_folder = "\\server\tcbuild$\Testers\_VM Update Instructions\03.09.2021 RELEASE\_Full DB Restoration\"
$MSSQLDataPath = "C:\Program Files\Microsoft SQL Server\MSSQL12.MSSQLSERVER\MSSQL\DATA\"
$queryTimeout = 720
$excludeSqlCmds = "1.DBRestore.sql"
$files = Get-ChildItem -path "$($release_bak_folder)\*" -Include "*.sql" -exclude $excludeSqlCmds | Sort-Object -Property Name
$dbs = @(
	@{
		DbName = "BaltBetM"
		BackupFile = "BaltBetM.bak"
		RelocateFiles = @(
			@{
				SourceName = "BaltBetM"
				FileName = "BaltBetM.mdf"
			}
			@{
				SourceName = "CoefFileGroup"
				FileName = "CoefFileGroup.mdf"
			}
			@{
				SourceName = "BaltBet"
				FileName = "BaltBet.ldf"
			}
		)
	}
	@{
		DbName = "BaltBetMMirror"
		BackupFile = "BaltBetM.bak"
		RelocateFiles = @(
			@{
				SourceName = "BaltBetM"
				FileName = "BaltBetMMirror.mdf"
			}
			@{
				SourceName = "CoefFileGroup"
				FileName = "CoefFileGroupMirror.mdf"
			}
			@{
				SourceName = "BaltBet"
				FileName = "BaltBetMirror.ldf"
			}
		)
	}
	@{
		DbName = "BaltBetWeb"
		BackupFile = "BaltBetWeb.bak"
		RelocateFiles = @(
			@{
				SourceName = "BaltBetWeb"
				FileName = "BaltBetWeb.mdf"
			}
			@{
				SourceName = "Files"
				FileName = "Files"
			}
			@{
				SourceName = "BaltBetWeb_log"
				FileName = "BaltBetWeb.ldf"
			}
		)
	}
		<#@{
		DbName = "ParserNew"
		BackupFile = "parser.bak"
		RelocateFiles = @(
			@{
				SourceName = "ParserNew"
				FileName = "ParserNew.mdf"
			}
			@{
				SourceName = "ParserNew_log"
				FileName = "ParserNew_log.ldf"
			}
		)
	} #>
)

function RestoreSqlDb($db_params) {
	foreach ($db in $db_params){
		$RelocateFile = @() 
        $dbname = $db.DbName
		$KillConnectionsSql=
			"
			USE master
			GO
			ALTER DATABASE [$dbname] SET SINGLE_USER WITH ROLLBACK IMMEDIATE
			GO
			DROP DATABASE [$dbname]
			GO
			"
		Invoke-Sqlcmd -Verbose -ServerInstance $env:COMPUTERNAME -Query $KillConnectionsSql -ErrorAction continue
		if ($db.ContainsKey('RelocateFiles')){
			foreach ($dbFile in $db.RelocateFiles) {
				$RelocateFile += New-Object Microsoft.SqlServer.Management.Smo.RelocateFile($dbFile.SourceName, ("{0}{1}" -f $MSSQLDataPath, $dbFile.FileName))
			}
			$dbBackupFile = $release_bak_folder + $db.BackupFile
			Restore-SqlDatabase -Verbose -ServerInstance $env:COMPUTERNAME -Database $db.DbName -BackupFile  $dbBackupFile -RelocateFile $RelocateFile -ReplaceDatabase
			Push-Location C:\Windows
		}else{
			Restore-SqlDatabase -Verbose -ServerInstance $env:COMPUTERNAME -Database $db.DbName -BackupFile  $dbBackupFile -ReplaceDatabase
			Push-Location C:\Windows			
		}
	}
}

RestoreSqlDb($dbs)


# Выполняем скрипты из актуализации BaltBetM
$qwr=
			"
			ALTER DATABASE BaltBetM
			COLLATE Cyrillic_General_CI_AS
			GO
			"
Invoke-Sqlcmd -Verbose -ServerInstance $env:COMPUTERNAME -Query $qwr -ErrorAction continue


#применяем скрипты к базе $dbname
$dbname = 'BaltBetM'
foreach ($file in $files) {
	Write-Host -ForegroundColor Gray "EXECUTED STARETED: " $file
	Invoke-Sqlcmd -verbose -QueryTimeout $queryTimeout -ServerInstance $env:COMPUTERNAME -Database $dbname -InputFile $file -ErrorAction continue
	Write-Host -ForegroundColor Green "EXECUTED SUCCESSFULLY: " $file 
}

#Удаляем старые папки
$local_old_folders = @('C:\=Full DB Restoration','C:\_Full DB Restoration')
foreach ($old_folder in $local_old_folders){
	Remove-Item $old_folder -Recurse -Force -ErrorAction Ignore
}

<#
$services = @(
    'ActivityService',
    'ReportService'
)

#>

$user_service = "testkernel_svc@gkbaltbet.local"
$password_service = "GldycLIFKM2018"


Write-Host -ForegroundColor Green "[INFO] Stopping IIS ..."
Stop-Service W3SVC

#0. Замена webapiAuth
$old_hostname = "VM-HM1-WS2"
$hostname = $env:COMPUTERNAME
mkdir C:\devops
Copy-Item -Path "\\server\tcbuild$\Testers\_VM Update Instructions\03.09.2021 RELEASE\webapiAuth.zip" -Destination "C:\devops\"
Remove-Item -Path "C:\inetpub\webapiAuth\*" -Recurse -Force
Expand-Archive -LiteralPath "c:\devops\webapiAuth.zip" -DestinationPath "C:\inetpub\webapiAuth\"
Write-Host -ForegroundColor Green "[INFO] Change config C:\inetpub\webapiAuth\Web.config ..."
((Get-Content -Encoding UTF8 -Path "C:\inetpub\webapiAuth\Web.config") -replace $old_hostname, $hostname) | Set-Content -Encoding UTF8 -Path "C:\inetpub\webapiAuth\Web.config"
Write-Host -ForegroundColor Green "[INFO] Removing devops folder ..."
Remove-Item -Path "C:\devops" -Force -Recurse

#1.	ActivitiesService
Stop-Service -Name ActivityService
Write-Host -ForegroundColor Green "[INFO] Delete Baltbet.ActivityService ..."
(Get-WmiObject win32_service -Filter "name='ActivityService'").delete()
Move-Item -Path "C:\ActivitiesService" -Destination "C:\Services\" -Force
Write-Host -ForegroundColor Green "[INFO] Ctreating Baltbet.ActivityService ..."
C:\Services\ActivitiesService\Baltbet.ActivitiesService.exe install
Write-Host -ForegroundColor Green "[INFO] Change Baltbet.ActivityService credentials..."
sc.exe config "ActivityService" obj= "$user_service" password= "$password_service"
Start-Service -Name "ActivityService"


# Пункты 2-8 инструкции
$folders_to_delete = @(
    'C:\BestBetsInitialize',
    'C:\CoefSumConverter',
    'C:\Config',
    'C:\Sites',
    'C:\Scripts',
    'C:\PreDeploy',
    'C:\EventGroupCommentConverter'
)

foreach ($folder in $folders_to_delete) {
    if (Test-Path -Path $folder) {
        Write-Host "Removing $folder ..."
        Remove-Item -Path $folder -Force -Recurse
    }
    else {
        Write-Host "Folder $folder doesn't exist."
    }
}

#9. Перенос IdentificationServiceCPS и IdentificationServiceCOM
Write-Host -ForegroundColor Green "[INFO] Moving IdentificationServiceCPS ..."
Move-Item -Path "C:\IdentificationServiceCPS" -Destination "C:\Services\" -Force

Write-Host -ForegroundColor Green "[INFO] Moving IdentificationServiceCOM ..."
Move-Item -Path "C:\IdentificationServiceCOM" -Destination "C:\Services\" -Force

#10. ReportService
Stop-Service -Name BaltBetReportService
#Remove-Service -Name BaltBetReportService
Write-Host -ForegroundColor Green "[INFO] Removing BaltBetReportService ..."
(Get-WmiObject win32_service -Filter "name='BaltBetReportService'").delete()
Move-Item -Path "C:\ReportService" -Destination "C:\Services\" -Force
Write-Host -ForegroundColor Green "[INFO] Creating ReportService ..."
C:\Services\ReportService\ReportService.exe install
Write-Host -ForegroundColor Green "[INFO] Change ReportService credentials..."
sc.exe config "BaltBetReportService" obj= "$user_service" password= "$password_service"
Write-Host -ForegroundColor Green "[INFO] Starting BaltBetReportService ..."
Start-Service -Name "BaltBetReportService"


Write-Host -ForegroundColor Green "[INFO] Starting IIS ..."
Start-Service W3SVC
