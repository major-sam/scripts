<#
    Edit-Configs
    Скрипт ищет конфиги (1. Функция Get-ConfigsList) в указанных папках (1) и заменяет (2. Функция Edit-Config) 
    в этих конфигах IP адрес и имя хоста на локальные.
#>

function Get-ConfigsList 
{
    <#
        1. Функция Get-ConfigsList 
        Получает на вход полный путь к папке (1.1) и выводит список всех файлов с расширениями 
        xml, json,config внутри указанной папки(1.2)
    #>
    param 
    (
        $ComponentPath                                                                  # (1.1)
    )

    Get-ChildItem -Path $ComponentPath -Recurse -Include "*.xml","*.json","*.config"    # (1.2)
}

function Edit-Config 
{
    <#
        2. Функция Edit-Config
        Получает на вход полный путь к конфиг файлу (2.1), загружает его содержимое, 
        заменяет адреса и хостнеймы на адрес и нейм локальной машины и перезаписывает конфиг (2.2). 
    #>
    param 
    (
        $ConfigPath                                                                                                                                         # (2.1)
    )

    $oldIp = "172.16.1.124"
    $oldHostname = "vm-n1-ws4"
    $IPAddress = "$((Get-NetIPAddress -InterfaceAlias Ethernet -AddressFamily IPv4).IPAddress)"

    ((Get-Content -Encoding UTF8 -LiteralPath $ConfigPath) -replace $oldIp,$IPAddress)| Set-Content -Encoding UTF8 -LiteralPath $ConfigPath                 # (2.2)
	((Get-Content -Encoding UTF8 -LiteralPath $ConfigPath) -replace $oldHostname,$env:COMPUTERNAME)| Set-Content -Encoding UTF8 -LiteralPath $ConfigPath    # (2.2)

}

<#
        MAIN
#>
$inetpub = Get-ChildItem -Path C:\inetpub -Exclude "logs","temp","wwwroot","web.config" 
$folders = @()
foreach ($fold in $inetpub.Name)
{
    $folders += "inetpub\$fold"                                                             # (1)
}
$folders += 'Kernel'
$folders += 'KernelWeb'
$folders += 'Services'
foreach ($folder in $folders)
{
    $configsList = Get-ConfigsList -ComponentPath "C:\$folder"
    foreach ($config in $configsList.FullName)
    {
        Edit-Config -ConfigPath $config
    }
}