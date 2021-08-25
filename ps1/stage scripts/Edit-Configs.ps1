function Get-Configs 
{
    <#
        Функция Get-Configs 
        Получает на вход полный путь к папке (1) и выводит список всех файлов с расширениями 
        xml, json,config внутри указанной папки(2)
    #>
    param 
    (
        $ComponentPath # (1)
    )

    Get-ChildItem -Path $ComponentPath -Recurse -Include "*.xml","*.json","*.config" # (2)
}

function Edit-Config 
{
    <#
        Функция Get-Configs 
        Получает на вход полный путь к конфиг файлу (1), загружает его содержимое(2), 
        заменяет адреса и хостнеймы на адрес и нейм локальной машины(3) и перезаписывает конфиг(4). 
    #>
    param 
    (
        $ConfigPath # (1)
    )

    $oldIp = "172.16.1.124" #  Сторка ip в конфиге которую надо заменить
    $oldHostname = "vm-n1-ws4" # Строка хостнейма в конфиге которую надо заменить
    $IPAddress = "$((Get-NetIPAddress -InterfaceAlias Ethernet -AddressFamily IPv4).IPAddress)" # IP адрес машины. Он будет вставляться вместо $oldIp
    $config = Get-Content -Encoding UTF8 -Path $ConfigPath # (2)

    for ($i=0; $i -lt $config.Length; $i++)
    {
        $config[$i] = $config[$i].Replace($oldIp,$IPAddress) # (3)
        $config[$i] = $config[$i].Replace($oldHostname,$env:COMPUTERNAME)
    }

    Set-Content -Encoding UTF8 -Path $ConfigPath -Value $config # (4)
}

<#
        MAIN
#>
$inetpub = Get-ChildItem -Path C:\inetpub -Exclude "logs","temp","wwwroot","web.config" # Получает имена папок в inetpub за исключением системных
$folders = @()
foreach ($fold in $inetpub.Name)
{
    $folders += "inetpub\$fold"
}
$folders += 'Kernel'
$folders += 'KernelWeb'
$folders += 'Services' # Генерирует список папок, где будет проверяться наличие конфигов 
foreach ($folder in $folders)
{
    $configsList = Get-Configs -ComponentPath "C:\$folder"
    foreach ($config in $configsList.FullName)
    {
        Edit-Config -ConfigPath $config # Редактирует функцией Edit-Config каждый конфиг в каждой папке из $folders списка 
    }
}