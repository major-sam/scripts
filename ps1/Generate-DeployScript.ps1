<#
    Generate-DeployScript
    Скрипт получает на вход имя сервиса и тип его развертывания (Site или Service).
    Создает шаблонный скрипт для развертывания какого-либо сервиса по пути C:\Users\$env:USERNAME\Desktop\
#>

Param (
    [Parameter(Mandatory=$true)]
    [string]$ServiceName,

    [Parameter(Mandatory=$true)]
    [ValidateSet("Site","Service")]
    [string]$ServiceType
)

$GeneratedScriptFileName = "Deploy-$ServiceName.ps1"
switch ($ServiceType)
{
    "Site" {$PathToParentFolder = "C:\inetpub"}
    "Service" {$PathToParentFolder = "C:\Services"}
}


$TemplateScriptContent = 
"<#
    $ServiceName
    <Здесь должно быть ваше описание скрипта>
#>
Param (
    [Parameter(Mandatory=`$true)]
    [ValidateSet('TEST','STAGE','PROD')]
    [string]`$Environment = 'TEST'
)


function Deploy-$ServiceName
{
    param ()
    `$ServiceName = '$ServiceName'
    `$ServiceFolderPath = '$PathToParentFolder\$ServiceName'

    # Удаление старой конфигурации
    # <--- писать тут --->
    # 


    # Редактирование конфигов
    # <--- писать тут --->
    # 


    # Настройка сервиса
    # <--- писать тут --->
    # 

}


# Определение переменных в зависимости от выбранного окружения
switch (`$Environment)
{
    'PROD' {Write-Host 'Not complited. Run TEST env';exit}
    'STAGE' {Write-Host 'Not complited. Run TEST env';exit}
    'TEST' {Write-Host 'Not complited. Run TEST env';exit}
}


# Загрузка доп модулей
# <--- писать тут --->
# 

Deploy-$ServiceName # Парметры функции
"


New-Item -Path "C:\Users\$env:USERNAME\Desktop\$GeneratedScriptFileName" -ItemType File -Value $TemplateScriptContent
$ScriptFullPath = (Get-Item -Path "C:\Users\$env:USERNAME\Desktop\$GeneratedScriptFileName").FullName
Write-Host -ForegroundColor Green "Создан новый скрипт: $ScriptFullPath"
