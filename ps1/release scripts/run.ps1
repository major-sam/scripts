<#
Скрипт для запуска актуализации на ВМ.
Скрипт скопировать к себе на ПК.
Изменить, если необходимо, путь к скрипту актуализации (переменная $update_script).
Запустить PowerShell с правами администратора.
Перейти в каталог, куда был скопирован скрипт.
Запустить скрипт run.ps1, при запуске необходимо передать параметр с номером ВМ: run.ps1 -Machine <НОМЕР_ВМ>

    Например:
    .\run.ps1 -Machine VM15
#>


# Обязательная переменная передается через ключ -Machine при запуске run.ps1. По нажатию Tab осуществляется автоматический выбор существующих окружений
Param (
    [Parameter(Mandatory=$true)]
    [ValidateSet(
        "VM1",
        "VM2",
        "VM3",
        "VM4",
        "VM5",
        "VM6",
        "VM7",
        "VM8",
        "VM9",
        "VM10",
        "VM11",
        "VM12",
        "VM13",
        "VM14",
        "VM15",
        "VM16",
        "VM17",
        "VM18",
        "VM19",
        "VM20",
        "VM21",
        "VM22",
        "VM23",
        "ST1",
        "ST2",
        "ST3",
        "ST4",
        "ST-TT"
        )]
    [string]$Machine
)
#$vm_num = $args[0]

# Указать путь до основного скрипта
$update_script = "\\server\tcbuild$\Testers\_VM Update Instructions\10.09.2021 RELEASE\10.09.2021 RELEASE.ps1"

function Get-VmHostname {
    param (
        [int16]$MachineNum
    )

    $vm_hostname = ""
    switch ( $MachineNum ) {
        # APKTEST-P0
        "VM1" { $vm_hostname = 'VM1APKTEST-P0' }
        "VM2" { $vm_hostname = 'VM2APKTEST-P0' }
        "VM3" { $vm_hostname = 'VM3APKTEST-P0' }
        "VM4" { $vm_hostname = 'VM4APKTEST-P0' }
        "VM5" { $vm_hostname = 'VM5APKTEST-P0' }
        # APKTEST-P3
        "VM6" { $vm_hostname = 'VM1APKTEST-P3' }
        "VM7" { $vm_hostname = 'VM2APKTEST-P3' }
        "VM8" { $vm_hostname = 'VM3APKTEST-P3' }
        "VM9" { $vm_hostname = 'VM4APKTEST-P3' }
        "VM10" { $vm_hostname = 'VM5APKTEST-P3' }
        # HM1APKTEST-P0
        "VM11" { $vm_hostname = 'VM-HM1-WS1' }
        "VM12" { $vm_hostname = 'VM-HM1-WS2' }
        "VM13" { $vm_hostname = 'VM-HM1-WS3' }
        "VM14" { $vm_hostname = 'VM-HM1-WS4' }
        "VM15" { $vm_hostname = 'VM-HM1-WS5' }
        "VM16" { $vm_hostname = 'VM-HM1-WS6' }
        # HM-N1
        "VM17" { $vm_hostname = 'VM-N1-WS1' }
        "VM18" { $vm_hostname = 'VM-N1-WS2' }
        "VM19" { $vm_hostname = 'VM-N1-WS3' }
        "VM20" { $vm_hostname = 'VM-N1-WS4' }
        "VM21" { $vm_hostname = 'VM-N1-WS5' }
        "VM22" { $vm_hostname = 'VM-N1-WS6' }
        "VM23" { $vm_hostname = 'VM-N1-WS7' }
        # Stage
        "ST1" { $vm_hostname = 'VM1APKTEST-P1' }
        "ST2" { $vm_hostname = 'VM-P1-WS2' }
        "ST3" { $vm_hostname = 'VM-P1-WS4' }
        "ST4" { $vm_hostname = 'VM-P1-WS5' }
        "ST-TT" { $vm_hostname = 'VM-N7-WS4' }        
    }
    Write-Host "[INFO] VM is in list.." -NoNewline -ForegroundColor Green
    if ($vm_hostname) {
        Write-Host "OK" -ForegroundColor Green
        return $vm_hostname
    }
    else {
        Write-Host "FAILD" -ForegroundColor Red
        break
    }
    
}

Write-Host "[INFO] VM_NUMBER: $Machine" -ForegroundColor Green
$vm_hostname = Get-VmHostname($Machine)
Invoke-Command -FilePath $update_script -ComputerName $vm_hostname
