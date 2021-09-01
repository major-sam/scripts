<#
    Скрипт на раскатку стейджа по задаче DEVOPS-116 
    https://jira.baltbet.ru:8443/browse/DEVOPS-116
#>

$PathToSqlScripts = "\\server\enesudimov\stage"


$PathToMobile = "\\server\tcbuild$\WebTouchDev\ARCHI-51.1.0.0.188..f5be510f.zip"
$PathToTouch = "\\server\tcbuild$\WebPda\ARCHI-51.185.cf085c04.zip"
$PathToCoefService = "\\server\tcbuild$\ServerDeploy\CoefService\1.0.60.0"
$PathToReportService = "\\server\tcbuild$\ReportService\1.0.97"

Remove-Item -Path "C:\inetpub\Mobile\*" -Recurse -Exclude "Web.config" # переработать исключения
Expand-Archive -LiteralPath "$PathToMobile" -DestinationPath "C:\inetpub\Mobile\"

Remove-Item -Path "C:\inetpub\baltplaymobile\*" -Recurse -Exclude "Web.config" 
Expand-Archive -LiteralPath "$PathToTouch" -DestinationPath "C:\inetpub\baltplaymobile\"

Stop-Service -Name "BaltBetReportService" -Verbose
Remove-Item -Path "C:\ReportService\" -Recurse -Verbose
Copy-Item -LiteralPath "$PathToReportService" -Recurse -Destination "C:\Services\ReportService\" -Verbose
((Get-Content -Path "C:\Services\ReportService\ReportService.exe.config" -Encoding UTF8) -replace 'findValue="wcf.kernel.host"','findValue="test.wcf.host"')|Set-Content -Path "C:\Services\ReportService\ReportService.exe.config" -Encoding UTF8
New-Service -Name "BaltBetReportService" -BinaryPathName "C:\Services\ReportService\ReportService.exe" -StartupType Automatic 
Start-Service -Name "BaltBetReportService" -Verbose

Remove-Item -Path "C:\CoefService\*" -Recurse -Verbose
Remove-Item -Path "C:\CoefServiceMirror\*" -Recurse -Verbose
Copy-Item -LiteralPath "$PathToCoefService" -Recurse -Destination "C:\Services\CoefService" -Verbose
((Get-Content -Path "C:\Services\CoefService\appsettings.json" -Encoding UTF8) -replace 'Kernel.Coefs.Mirror','Kernel.Coefs')|Set-Content -Path "C:\Services\CoefService\appsettings.json" -Encoding UTF8
Copy-Item -LiteralPath "$PathToCoefService" -Recurse -Destination "C:\Services\CoefServiceMirror" -Verbose
((Get-Content -Path "C:\Services\CoefServiceMirror\appsettings.json" -Encoding UTF8) -replace 'catalog=BaltBetM','catalog=BaltBetMMirror')|Set-Content -Path "C:\Services\CoefServiceMirror\appsettings.json" -Encoding UTF8

Invoke-Sqlcmd -verbose -ServerInstance $env:COMPUTERNAME -Database "BaltBetM" -InputFile "$PathToSqlScripts\ARCHI-51.sql" -ErrorAction Stop
Invoke-Sqlcmd -verbose -ServerInstance $env:COMPUTERNAME -Database "BaltBetMMirror" -InputFile "$PathToSqlScripts\ARCHI-51.sql" -ErrorAction Stop
Invoke-Sqlcmd -verbose -ServerInstance $env:COMPUTERNAME -Database "BaltBetWeb" -InputFile "$PathToSqlScripts\ARCHI-51Com.sql" -ErrorAction Stop



