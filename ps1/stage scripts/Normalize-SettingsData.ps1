<#
    Normalize-SettingsData
    Скрипт выгружает данные из таблицы настроек UniRu и WebApi.Auth (1) на локальном sql сервере, заменяет в даннных 
    IP (2) и имя хоста (3) на локальные и выгружает их в txt файл (4)
#>

$DataBases = ("UniRu", "WebApi.Auth")
$TempDirPath = "C:\temp"
$oldIp = "172.16.1.124"
$oldHostname = "VM-N1-WS4"
$IPAddress = "$((Get-NetIPAddress -InterfaceAlias Ethernet -AddressFamily IPv4).IPAddress)"

foreach ($DataBase in $DataBases)
{
    if ($DataBase -match "Auth")
    {   
        $TableName = "Options" 
    } 
    else 
    {
        $TableName = "SiteOptions"
    }

    $FilePath = "$TempDirPath\$DataBase.$env:COMPUTERNAME.txt"
    if (!(Test-Path -Path $TempDirPath))
    {
        New-Item -Path $TempDirPath -ItemType Directory -Verbose
    }
    bcp "SELECT Name, Value FROM [$DataBase].Settings.$TableName ORDER BY Name" queryout $FilePath -T -c -w -S $env:COMPUTERNAME    # (1)
    
    $FileContent = Get-Content -LiteralPath $FilePath -Encoding UTF8
    for ($i=0; $i -lt $FileContent.Length; $i++)
    {
        $FileContent[$i] = $FileContent[$i].Replace($oldIp,$IPAddress)                                                              # (2)
        $FileContent[$i] = $FileContent[$i].Replace($oldHostname,$env:COMPUTERNAME)                                                 # (3)
    }

    $NewFilePath = "$TempDirPath\New.$DataBase.$env:COMPUTERNAME.txt"
    Set-Content -Encoding UTF8 -LiteralPath $NewFilePath -Value $FileContent                                                        # (4)
}
