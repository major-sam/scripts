<#

#>

function Write-PrettyMessage
{
    <#
        1. Функция Write-PrettyMessage
        Получает на вход строку сообщения (1.1), строку типа сообщения (пока Great и Standart) (1.2), и цвет (1.3).
        В зависимости от типа сообщения выводит текст в разном виде.
    #>
    param (
        $Message,       # (1.1)
        $MessageType,   # (1.2)
        $Color          # (1.3)
    )

    if ($MessageType -eq "Great")           
    {
        Write-Host -ForegroundColor $Color "====================================================================================================="
        Write-Host  " "
        Write-Host  -ForegroundColor $Color $Message
        Write-Host  " "        
        Write-Host -ForegroundColor $Color "====================================================================================================="      
    }
    elseif ($MessageType -eq "Standart")
    {
        Write-Host -ForegroundColor $Color "====================================================================================================="
        Write-Host  -ForegroundColor $Color $Message  
        Write-Host -ForegroundColor $Color "====================================================================================================="  
    }
}

function Switch-Services
{
    <#
        2. Функция Switch-Services
        Получает на вход строку ожидаемого состояния (2.1) сервиса (в формате Stopped или Running) и список сервисов (2.2).
        Проверяет, соответствует ли текущее состояние каждого сервиса ожидаемому (2.3). Если нет, то переключает сервис в 
        ожидаемое состояние (2.4).
    #>
    param (
        $ExpectedState,                                                         # (2.1)
        $ServicesList                                                           # (2.2)
    )

    foreach ($service in $ServicesList)
    {
        $CurrentState = (Get-Service -Name $service).Status
        if ($CurrentState -ne $ExpectedState)                                   # (2.3)
        {
            if ($ExpectedState -eq "Stopped")                                                                      
            {
                Write-Host -ForegroundColor Green "[INFO] Stopping $Service"
                Stop-Service "$Service" -Verbose                                # (2.4)
            }
            elseif ($ExpectedState -eq "Running") {
                Write-Host -ForegroundColor Green "[INFO] Starting $Service"
                Start-Service "$Service" -Verbose                               # (2.4)
            }
        }        
    }
}


Write-PrettyMessage -Message "Run All scripts" -MessageType "Great" -Color Green
Write-PrettyMessage -Message "Stop Services" -MessageType "Standart" -Color Green
$services = (
    "BaltBetKernel",
    "BaltBetKernelWeb",
    "Baltbet.Payment.BalanceReport",
    "BaltBet.SuperExpress.Service",
    "CampaignService",
    "MessageService",
    "NotificationService",
    "W3SVC"
)

Switch-Services -ExpectedState "Stopped" -ServicesList $services 


Write-PrettyMessage -Message "Run Edit-Configs.ps1" -MessageType "Standart" -Color Green
C:\Users\enesudimov\Desktop\Normalize-Stage\Edit-Configs.ps1

Write-PrettyMessage -Message "Generate and run sql scripts" -MessageType "Standart" -Color Green
$ScriptsFolder = "\\server\enesudimov\stage\"
$ScriptsFiles = Get-ChildItem -Path "$ScriptsFolder*" -Include *.sql
$oldIp = '172.16.1.217'
$oldHostname = 'VM1APKTEST-P1'
$IPAddress = "$((Get-NetIPAddress -InterfaceAlias Ethernet -AddressFamily IPv4).IPAddress)"
if (!(Test-Path -Path "C:\temp\"))
{
    New-Item -ItemType Directory -Path "C:\temp\"
}
foreach ($file in $ScriptsFiles.FullName)
{
    $FileName = $file.Split('\')[-1]
    $newFile = "C:\temp\$fileName"
    ((Get-Content -Encoding UTF8 -LiteralPath $file) -replace $oldIp,$IPAddress)| Set-Content -Encoding UTF8 -LiteralPath $newFile
	((Get-Content -Encoding UTF8 -LiteralPath $newFile) -replace $oldHostname,$env:COMPUTERNAME)| Set-Content -Encoding UTF8 -LiteralPath $newFile  
    Invoke-Sqlcmd -verbose -ServerInstance $env:COMPUTERNAME -Database "master" -InputFile $newFile -ErrorAction Stop
    Set-Location C:\
}

Write-PrettyMessage -Message "Start Services" -MessageType "Standart" -Color Green
Switch-Services -ExpectedState "Running" -ServicesList $services

