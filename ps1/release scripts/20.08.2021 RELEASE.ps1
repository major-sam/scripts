<#
Скрипт для равертывания нового релиза 20-08-2021
powershell.exe -file "\\server\tcbuild$\Testers\_VM Update Instructions\20.08.2021 RELEASE\20.08.2021 RELEASE.ps1"

Проверка: +79112492620 Qwerty1z
#>
$ProgressPreference = 'SilentlyContinue'
$release_folder = "\\server\tcbuild$\Testers\_VM Update Instructions\20.08.2021 RELEASE"
$queryTimeout = 720
$excludeSqlCmds = "1.DBRestore.sql"
$files = Get-ChildItem -path "$($release_folder)\_Full DB Restoration\*" -Include "*.sql" -exclude $excludeSqlCmds | Sort-Object -Property Name
$fullbkupfile = "$($release_folder)\_Full DB Restoration\BaltBetM.bak"


# Копируем Baltbet.Payment.BalanceReport
mkdir "C:\Services\Baltbet.Payment.BalanceReport"
Write-Host -ForegroundColor Green "[INFO] Copy Baltbet.Payment.BalanceReport files..."
Copy-Item  -path "$($release_folder)\Baltbet.Payment.BalanceReport\*" -Recurse -Force -Destination "C:\Services\Baltbet.Payment.BalanceReport"

# Создаем сервис Baltbet.Payment.BalanceReport
Write-Host -ForegroundColor Green "[INFO] Creating Baltbet.Payment.BalanceReport service..."
try {
    New-Service -Name Baltbet.Payment.BalanceReport -BinaryPathName C:\Services\Baltbet.Payment.BalanceReport\Baltbet.Payment.BalanceReport.exe -DisplayName Baltbet.Payment.BalanceReport -StartupType Automatic -ErrorAction Stop
    #New-Service -Name CampaignService -BinaryPathName C:\Services\CampaignService\CampaignService.exe -StartupType Automatic -Verbose
    Write-Host -ForegroundColor Green "[INFO] Service Baltbet.Payment.BalanceReport created"
}
catch {
    Write-Host -ForegroundColor RED "[ALERT] Can't create service Baltbet.Payment.BalanceReport"
}
# Запускаем сервис Baltbet.Payment.BalanceReport
Write-Host -ForegroundColor Green "[INFO] Starting service Baltbet.Payment.BalanceReport..."
try {
    Start-Service -Name "Baltbet.Payment.BalanceReport" -Verbose -ErrorAction continue
}
catch {
    Write-Host -ForegroundColor RED "[ALERT] Can't start service Baltbet.Payment.BalanceReport"
}


# Обнавляем NotificationService
Write-Host -ForegroundColor Green "[INFO] Updating NotificationService..."
Remove-Item -Recurse -Force  C:\Services\NotificationService\*
Copy-Item  -path "$($release_folder)\1.0.0.54\*" -Recurse -Destination "C:\Services\NotificationService"

$dbname = "BaltBetM"
$KillConnectionsSql=
"
USE master
GO
ALTER DATABASE [$dbname] SET SINGLE_USER WITH ROLLBACK IMMEDIATE

GO
DROP DATABASE [$dbname]
GO
"
## Дропаем старую БД $dbname
Invoke-Sqlcmd -Verbose -ServerInstance $env:COMPUTERNAME -Query $KillConnectionsSql -ErrorAction continue
# Разворачиваем базу $dbname  
$RelocateData = New-Object Microsoft.SqlServer.Management.Smo.RelocateFile("BaltBetM", "C:\Program Files\Microsoft SQL Server\MSSQL12.MSSQLSERVER\MSSQL\DATA\$dbname.mdf")
$RelocateData2  = New-Object Microsoft.SqlServer.Management.Smo.RelocateFile("CoefFileGroup", "C:\Program Files\Microsoft SQL Server\MSSQL12.MSSQLSERVER\MSSQL\DATA\CoefFileGroup.mdf")
$RelocateLog  = New-Object Microsoft.SqlServer.Management.Smo.RelocateFile("BaltBet", "C:\Program Files\Microsoft SQL Server\MSSQL12.MSSQLSERVER\MSSQL\DATA\$dbname.ldf")
Restore-SqlDatabase -Verbose -ServerInstance $env:COMPUTERNAME -Database $dbname -BackupFile  $fullbkupfile -RelocateFile @($RelocateData,$RelocateData2,$RelocateLog) -ReplaceDatabase

# Выполняем скрипты из актуализации

foreach ($file in $files) {
	Write-Host -ForegroundColor Gray "EXECUTED STARETED: " $file
	Invoke-Sqlcmd -verbose -QueryTimeout $queryTimeout -ServerInstance $env:COMPUTERNAME -Database $dbname -InputFile $file -ErrorAction continue
	Write-Host -ForegroundColor Green "EXECUTED SUCCESSFULLY: " $file 
}


$query_insert = "
UPDATE UniRu.Settings.SiteOptions SET Value='http://localhost:8123/api/AccountFiles/Cps/completingPassportData/{0}' WHERE Name = 'PlayerIdentificationSettings.DocumentUploadSettings.RecognitionCompletingPassportAddress'
IF @@ROWCOUNT = 0
INSERT INTO UniRu.Settings.SiteOptions (GroupId, Name, Value, IsInherited)
	VALUES (1,'PlayerIdentificationSettings.DocumentUploadSettings.RecognitionCompletingPassportAddress','http://localhost:8123/api/AccountFiles/Cps/completingPassportData/{0}',0)
GO
"
Invoke-Sqlcmd -QueryTimeout 360 -verbose -ServerInstance $env:COMPUTERNAME -Database "UniRu" -query $query_insert -ErrorAction continue
Restart-Service W3SVC