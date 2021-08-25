function Set-NewDataScript
{
    <#
        Функция Set-NewDataScript
        Получает на вход полный путь к экспортированным данным (1), имя базы данных (2), имя таблицы (3).
        Из полученных данных выделяет имя настройки (4) и его значение с учетом типа данных (5).
        Затем, составляет sql скрипт (6), который меняет значения в целевой базе и возвращает скрипт (7)
        в виде строки. 
    #>
    param 
    (
        $ExportFileContent,                                                                         # < (1)
        $DataBaseName,                                                                              # < (2)
        $TableName                                                                                  # < (3)
    )  

    $Query = ""
    foreach ($str in $ExportFileContent)
    {
        $OptionName = $str.Split("")[0]                                                             # < (4)
    
        try 
        {
            $OptionValue = $str.Split("")[1]/1                                                      # < (5)
        } 
        catch 
        {
            $OptionValue = $str.Split("")[1]
            $OptionValue = "'$OptionValue'"                                                         # < (5)
        }
    
        $Query += "                                                                                 
IF EXISTS (SELECT * FROM [$DataBaseName].Settings.$TableName
    WHERE Name = '$OptionName')
UPDATE [$DataBaseName].Settings.$TableName SET Value = $OptionValue
    WHERE Name = '$OptionName'
-- ELSE
--     INSERT INTO [$DataBaseName].Settings.$TableName (GroupId, Name, Value, IsInherited)
--     VALUES (1, '$OptionName', $OptionValue, 0);  
--------------------------------------------------------------------------------          
        "                                                                                           # ^ (6)
    } 
    return $Query                                                                                   # < (7)    
}

$ExportFilesFolderPath = "\\server\enesudimov\stage\data\ExportData"                                # Директория с экспортированными данными
$ExportFilesList = Get-ChildItem -Path $ExportFilesFolderPath\* -Include "*$env:COMPUTERNAME*"      # Список файлов в директории, отфильтрованный по имени машины в названии     

foreach ($file in $ExportFilesList.FullName)
{   
    if ($file -match "Auth")
    {
        $DataBaseName = "WebApi.Auth"
        $TableName = "Options"
    }
    else 
    {
        $DataBaseName = "UniRu"
        $TableName = "SiteOptions"        
    }
    $TableContent = Get-Content -Path $file -Encoding UTF8
    $Query = Set-NewDataScript -ExportFileContent $TableContent -DataBaseName $DataBaseName -TableName $TableName

    if (!(Test-Path C:\Deploy\SqlScripts\))
    {
        New-Item -Path C:\Deploy\SqlScripts\ -ItemType Directory -Verbose 
    }

    Set-Content -Path "C:\Deploy\SqlScripts\$DataBaseName.sql" -Encoding UTF8 -Value $Query
}