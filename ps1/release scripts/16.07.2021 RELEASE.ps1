#powershell.exe -file "\\server\tcbuild$\Testers\_VM Update Instructions\Jenkins\test\16.07.2021 RELEASE.ps1"



$tmp_folder = "c:\temp_dev"
$db = "BaltBetM"
$release_folder = "\\server\tcbuild$\Testers\_VM Update Instructions\16.07.2021 RELEASE"
mkdir $tmp_folder 
Copy-Item  -path "$release_folder\*" -include "*.sql" -Destination $tmp_folder
$files = Get-ChildItem -path "c:\temp_dev\*" -Include "*.sql"
try {
    foreach ($file in $files) {
        Invoke-Sqlcmd  -ServerInstance $env:COMPUTERNAME -Database $db -InputFile $file -ErrorAction continue
        Write-Host -ForegroundColor Green "EXECUTED SuCCESSFULLY: " $file 
    }
}
catch {
 Write-Host -ForegroundColor RED "FAILED TO EXECUTE: " $file
}
Push-Location -Path $env:USERPROFILE
Remove-Item -Recurse -Force  $tmp_folder

Expand-Archive  -Path \\server\tcbuild$\WebTouchDev\2021-07-16.develop.1302.4fedc954.zip -DestinationPath \inetpub\Mobile -Force
Expand-Archive  -Path \\server\tcbuild$\WebPda\2021-07-16.develop.1258.afad66e7.zip -DestinationPath \inetpub\baltplaymobile -Force
stop-service "BaltBetReportService"
Remove-Item -Recurse -Force C:\ReportService
mkdir C:\ReportService
Copy-Item  -path "$release_folder\ReportService\1.0.97\*" -Recurse -Destination "C:\ReportService"
start-service "BaltBetReportService"
Remove-Item -Recurse -Force C:\IdentificationService
mkdir C:\IdentificationServiceCPS
copy-Item  -path "$release_folder\IdentificationService\IdentificationServiceCPS\*" -Recurse -Destination "C:\IdentificationServiceCPS"
mkdir "C:\IdentificationServiceCOM"
copy-Item  -path "$release_folder\IdentificationService\IdentificationServiceCOM\*" -Recurse -Destination "C:\IdentificationServiceCOM"
Rename-Item -Path "C:\Downloads" -NewName "DownloadsCPS"
mkdir c:\DownloadsCOM 
((Get-Content -path C:\Kernel\Kernel.exe.config -encoding UTF8).replace('<add key="IdentificationServiceAddress" value="http://localhost:8081" />','<add key="IdentificationServiceAddress" value="http://localhost:8123" />')) | Set-Content -Path  C:\Kernel\Kernel.exe.config -encoding UTF8
((Get-Content -path C:\inetpub\baltbetcom\Web.config  -encoding UTF8).replace('<add key="AccountDocumentFilesUrl" value="http://localhost:8081/api/AccountFiles/Upload/Com/{0}/{1}/{2}" />',
    '<add key="AccountDocumentFilesUrl" value="http://localhost:8100/api/AccountFiles/Com/Upload/{0}/{1}/{2}" />')
    ) | Set-Content -Path "C:\inetpub\baltbetcom\Web.config" -encoding UTF8
Restart-Service W3SVC
Stop-Service "BaltBetKernel"
Stop-Service "BaltBetKernelWeb"