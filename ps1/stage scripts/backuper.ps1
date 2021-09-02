<#
Скрипт для создания бэкапов окружения и баз данных перед накаткой изменений

подразуемевается что делаться будет не более 1 раза в  сутки если чаще - то стоит изменить формат даты $currentDate  (dd-MM-yy-HH-mm-ss)

Список сервисова $bakFolders  лучше использовать в зависимости от окружения, но сейчас добавлен скип для несуществующих папок.В дальнейшем должно переехать в переменную окружения
#>

$ProgressPreference = 'SilentlyContinue'
$archiveFolder = "c:\$env:COMPUTERNAME.Archive"
#папка для архивов.  В дальнейшем надо унести в сеть
$bakFolders = ("c:\inetpub", "c:\kernel", "c:\kernelweb", "c:\Services")
#список папок сервисов для бэкапов
$excludeDB = "'master','model','msdb','tempdb'"
# исключить базы из  бэкапа "'master','model','msdb','tempdb'"  внешние ковыки обязательны - передается строка
$currentDate = Get-Date -Format "dd-MM-yy hh-mm"
# формат имени бэкапов - используется дата время
$currentArchive = Join-Path -Path  $archiveFolder -ChildPath $currentDate
# join пути к папке
$queryTimeout = 720
#максимальное время ожидания выполнения бэкапа в секундах

If(!(test-path $archiveFolder))
{
      New-Item -ItemType Directory -Force -Path $archiveFolder -Verbose
}

If(!(test-path $currentArchive))
{
      New-Item -ItemType Directory -Force -Path $currentArchive -Verbose
}

foreach ($folder in $bakFolders ){
    if (test-path $folder){
        Write-Host -ForegroundColor Green "[INFO] Copy $folder into archive folder..."
        Copy-Item -Path $folder -Destination $currentArchive -Force -Recurse -Verbose
    }
    else{
        write-host  -ForegroundColor Yellow "$folder not exists. Skipped"   
    }
}

$backupQuery =
"
DECLARE @name VARCHAR(50) -- database name  
DECLARE @path VARCHAR(256) -- path for backup files  
DECLARE @fileName VARCHAR(256) -- filename for backup  
DECLARE @fileDate VARCHAR(20) -- used for file name
 
-- specify database backup directory
SET @path = '$currentArchive\'  
 
-- specify filename format
SELECT @fileDate = CONVERT(VARCHAR(20),GETDATE(),112) 
 
DECLARE db_cursor CURSOR READ_ONLY FOR  
SELECT name 
FROM master.sys.databases 
WHERE name NOT IN ($excludeDB)  -- exclude these databases
AND state = 0 -- database is online
AND is_in_standby = 0 -- database is not read only for log shipping
 
OPEN db_cursor   
FETCH NEXT FROM db_cursor INTO @name   
 
WHILE @@FETCH_STATUS = 0   
BEGIN   
   SET @fileName = @path + @name + '_' + @fileDate + '.BAK'  
   BACKUP DATABASE @name TO DISK = @fileName  WITH COMPRESSION
 
   FETCH NEXT FROM db_cursor INTO @name   
END   

 
CLOSE db_cursor   
DEALLOCATE db_cursor
"

Write-Host -ForegroundColor Green "[INFO] Backup databases..."
Invoke-Sqlcmd -QueryTimeout $queryTimeout -verbose -ServerInstance $env:COMPUTERNAME -Database "master" -query $backupQuery -ErrorAction Stop

Write-Host -ForegroundColor Green "[INFO] Export data from settings..."
<#
.\exportDBData.ps1

Write-Host -ForegroundColor Green "[INFO] Compress archive folder..."
if (-not (test-path "$env:ProgramFiles\7-Zip\7z.exe")) {
Compress-Archive -Path $archiveFolder -DestinationPath "$archiveFolder.zip" -Verbose
throw "$env:ProgramFiles\7-Zip\7z.exe needed"}
else{
set-alias arch "$env:ProgramFiles\7-Zip\7z.exe"
arch a -tzip $archiveFolder   $archiveFolder }
Remove-Item -Force -Recurse $archiveFolder

Write-Host -ForegroundColor Green "[INFO] Copy archive to net folder..."
Copy-Item -Path "$archiveFolder.zip" -Destination "\\server\enesudimov\stage" -Verbose
#>