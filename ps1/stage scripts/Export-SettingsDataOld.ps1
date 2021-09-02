<# 
    Скрипт экспортирует данные из стейдж баз в файл ИМЯ_БД.ИМЯ_МАШИНЫ.txt
#>    
$hash = @{ 
    "vm1apktest-p1" = @{Uni = "UniCps"; Auth = "Auth-UniCps"};
    "vm-p1-ws2" = @{Uni = "UniRu"; Auth = "OAuth-UniRu"};
    "vm-p1-ws4" = @{Uni = "UniRu"; Auth = "Auth-UniRu"};
    "vm-p1-ws5" = @{Uni = "UniCps"; Auth = "WebApi.Auth"}
}

foreach ($value in $hash.$env:COMPUTERNAME.Values)
{
    if ($value -match "Auth")
    {   
        $TableName = "Options" 
    } 
    else 
    {
        $TableName = "SiteOptions"
    }
    $FilePath = "\\server\enesudimov\stage\data\$value.$env:COMPUTERNAME.txt"#"C:\$env:COMPUTERNAME.Archive\$value.$env:COMPUTERNAME.txt"
    bcp "SELECT Name, Value FROM [$value].Settings.$TableName ORDER BY Name" queryout $FilePath -T -c -w -S $env:COMPUTERNAME
}