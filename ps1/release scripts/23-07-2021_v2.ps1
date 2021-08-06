<#
Скрипт для равертывания 23.07 релиза
powershell.exe -file "\\server\tcbuild$\Testers\_VM Update Instructions\23.07.2021 RELEASE\23-07-2021_v2.ps1"
#>

$tmp_folder = "c:\temp_dev"
$db_CashBookService = "CashBookService"
$db_BaltBetM = "BaltBetM"
$release_folder = "\\server\tcbuild$\Testers\_VM Update Instructions\23.07.2021 RELEASE"

# Создаем временный каталог
mkdir $tmp_folder
mkdir "C:\_Full DB Restoration"
mkdir "C:\Services\CashBookService"

$query = "
CREATE DATABASE [$db_CashBookService]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'CashBookService', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL12.MSSQLSERVER\MSSQL\DATA\CashBookService.mdf' , SIZE = 5120KB , FILEGROWTH = 1024KB )
 LOG ON 
( NAME = N'CashBookService_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL12.MSSQLSERVER\MSSQL\DATA\CashBookService_log.ldf' , SIZE = 2048KB , FILEGROWTH = 10%)
GO
ALTER DATABASE [CashBookService] SET COMPATIBILITY_LEVEL = 120
GO
ALTER DATABASE [CashBookService] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [CashBookService] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [CashBookService] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [CashBookService] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [CashBookService] SET ARITHABORT OFF 
GO
ALTER DATABASE [CashBookService] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [CashBookService] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [CashBookService] SET AUTO_CREATE_STATISTICS ON(INCREMENTAL = OFF)
GO
ALTER DATABASE [CashBookService] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [CashBookService] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [CashBookService] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [CashBookService] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [CashBookService] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [CashBookService] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [CashBookService] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [CashBookService] SET  DISABLE_BROKER 
GO
ALTER DATABASE [CashBookService] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [CashBookService] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [CashBookService] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [CashBookService] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [CashBookService] SET  READ_WRITE 
GO
ALTER DATABASE [CashBookService] SET RECOVERY SIMPLE 
GO
ALTER DATABASE [CashBookService] SET  MULTI_USER 
GO
ALTER DATABASE [CashBookService] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [CashBookService] SET TARGET_RECOVERY_TIME = 0 SECONDS 
GO
ALTER DATABASE [CashBookService] SET DELAYED_DURABILITY = DISABLED 
GO
USE [CashBookService]
GO
IF NOT EXISTS (SELECT name FROM sys.filegroups WHERE is_default=1 AND name = N'PRIMARY') ALTER DATABASE [CashBookService] MODIFY FILEGROUP [PRIMARY] DEFAULT
GO
"
# create db_CashBookService
Invoke-Sqlcmd -QueryTimeout 360 -verbose -ServerInstance $env:COMPUTERNAME -Database "master" -query $query -ErrorAction continue
# Копируем sql скрипты для БД CashBookService#
Push-Location -Path $env:USERPROFILE
Copy-Item -verbose  -force -path "$release_folder\_Full DB Restoration\*" -include "*.sql" -Destination $tmp_folder

# Создаем директорию CashBookService в C:\Services и копируем содержимое из релиза
Copy-Item -verbose -Recurse -force -path "$release_folder\CashBookService\*" -Destination "C:\Services\CashBookService"

Copy-Item -verbose -path "$release_folder\_Full DB Restoration\*" -Recurse -Destination "C:\_Full DB Restoration"
# Останавливаем сервисы
Write-Host -ForegroundColor Green "Stopping BaltBetKernel"
Stop-Service "BaltBetKernel"
Write-Host -ForegroundColor Green "Stopping BaltBetKernelWeb"
Stop-Service "BaltBetKernelWeb"

#Применяем скрипты для базы CashBookService
$files = Get-ChildItem -path "$tmp_folder\*" -Include "*.sql"
try {
    foreach ($file in $files) {
     if($file.Name -like "*DBRestore*"){
        Invoke-Sqlcmd -QueryTimeout 360 -verbose -ServerInstance $env:COMPUTERNAME -InputFile $file -ErrorAction continue
     }
     else{
        Invoke-Sqlcmd -QueryTimeout 360 -verbose -ServerInstance $env:COMPUTERNAME -Database $db_BaltBetM -InputFile $file -ErrorAction continue
     }
		Push-Location -Path $env:USERPROFILE
        Write-Host -ForegroundColor Green "EXECUTED SuCCESSFULLY: " $file 
        Start-Sleep -Seconds 4
    }
}
catch {
 Write-Host -ForegroundColor RED "FAILED TO EXECUTE: " $file
}
try {
    Invoke-Sqlcmd -QueryTimeout 360 -ServerInstance $env:COMPUTERNAME -Database $db_CashBookService -InputFile $release_folder\DeployDb.sql -ErrorAction Stop
    Write-Host -ForegroundColor Green "EXECUTED SuCCESSFULLY: DeployDb.sql"
    Invoke-Sqlcmd -QueryTimeout 360 -ServerInstance $env:COMPUTERNAME -Database $db_CashBookService -InputFile $release_folder\InitDb.sql -ErrorAction Stop
    Write-Host -ForegroundColor Green "EXECUTED SuCCESSFULLY: InitDb.sql"
    Invoke-Sqlcmd -QueryTimeout 360 -ServerInstance $env:COMPUTERNAME -Database $db_CashBookService -InputFile $release_folder\UpdateCashBookServiceDb20210722.sql -ErrorAction Stop
    Write-Host -ForegroundColor Green "EXECUTED SuCCESSFULLY: UpdateCashBookServiceDb20210722.sql"
}
catch {
    Write-Host -ForegroundColor RED "FAILED TO EXECUTE: *.sql"
}
Push-Location -Path $env:USERPROFILE
# Удаляем временный каталог
remove-Item -Recurse -Force  $tmp_folder

