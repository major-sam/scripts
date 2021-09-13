<#
Скрипт для запуска актуализации на ВМ.
Скрипт скопировать к себе на ПК.
Изменить, если необходимо, путь к скрипту актуализации (переменная $update_script).
Запустить PowerShell с правами администратора.
Перейти в каталог, куда был скопирован скрипт.
Запустить скрипт run.ps1, при запуске необходимо передать параметр с номером ВМ: run.ps1 <НОМЕР_ВМ>

    Например:
    .\run.ps1 15
#>


# Переменная считывается из параметра переданного при запуске run.ps1
$vm_num = $args[0]

# Указать путь до основного скрипта
$update_script = "\\server\tcbuild$\Testers\_VM Update Instructions\10.09.2021 RELEASE\10.09.2021 RELEASE.ps1"

function Get-VmHostname {
    param (
        [int16]$vm_num
    )

    $vm_hostname = ""
    switch ( $vm_num ) {
        # APKTEST-P0
        1 { $vm_hostname = 'VM1APKTEST-P0' }
        2 { $vm_hostname = 'VM2APKTEST-P0' }
        3 { $vm_hostname = 'VM3APKTEST-P0' }
        4 { $vm_hostname = 'VM4APKTEST-P0' }
        5 { $vm_hostname = 'VM5APKTEST-P0' }
        # APKTEST-P3
        6 { $vm_hostname = 'VM1APKTEST-P3' }
        7 { $vm_hostname = 'VM2APKTEST-P3' }
        8 { $vm_hostname = 'VM3APKTEST-P3' }
        9 { $vm_hostname = 'VM4APKTEST-P3' }
        10 { $vm_hostname = 'VM5APKTEST-P3' }
        # HM1APKTEST-P0
        11 { $vm_hostname = 'VM-HM1-WS1' }
        12 { $vm_hostname = 'VM-HM1-WS2' }
        13 { $vm_hostname = 'VM-HM1-WS3' }
        14 { $vm_hostname = 'VM-HM1-WS4' }
        15 { $vm_hostname = 'VM-HM1-WS5' }
        16 { $vm_hostname = 'VM-HM1-WS6' }
        # HM-N1
        17 { $vm_hostname = 'VM-N1-WS1' }
        18 { $vm_hostname = 'VM-N1-WS2' }
        19 { $vm_hostname = 'VM-N1-WS3' }
        20 { $vm_hostname = 'VM-N1-WS4' }
        21 { $vm_hostname = 'VM-N1-WS5' }
        22 { $vm_hostname = 'VM-N1-WS6' }
        23 { $vm_hostname = 'VM-N1-WS7' }
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

Write-Host "[INFO] VM_NUMBER: $vm_num" -ForegroundColor Green
$vm_hostname = Get-VmHostname($vm_num)
Invoke-Command -FilePath $update_script -ComputerName $vm_hostname
