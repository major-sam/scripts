$archiveFolder = "c:\Archive"
$bakFolders = ("c:\inetpub", "c:\kernel", "c:\kernelweb", "c:\Services")
$currentDate = Get-Date -Format "dd-MM-yy"
$currentArchive = Join-Path -Path  $archiveFolder -ChildPath $currentDate
If(!(test-path $archiveFolder))
{
      New-Item -ItemType Directory -Force -Path $archiveFolder
}

If(!(test-path $currentArchive))
{
      New-Item -ItemType Directory -Force -Path $currentArchive
}

foreach ($folder in $bakFolders ){
    if (test-path $folder){
        Copy-Item -Path $folder -Destination $currentArchive -Force -Recurse
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
WHERE name NOT IN ('master','model','msdb','tempdb')  -- exclude these databases
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


Invoke-Sqlcmd -QueryTimeout 720 -verbose -ServerInstance $env:COMPUTERNAME -Database "master" -query $backupQuery -ErrorAction Stop


if (-not (test-path "$env:ProgramFiles\7-Zip\7z.exe")) {
Compress-Archive -Path $currentArchive -DestinationPath $currentArchive".zip"
throw "$env:ProgramFiles\7-Zip\7z.exe needed"}
else{
set-alias arch "$env:ProgramFiles\7-Zip\7z.exe"
sz a -tzip $currentArchive   $currentArchive }
Remove-Item -Force -Recurse $currentArchive 