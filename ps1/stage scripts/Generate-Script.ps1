$SiteOptionsPath = "C:\Users\enesudimov\Desktop\UniCps.VM1APKTEST-P1.txt"
$SiteOptions = Get-Content -Path $SiteOptionsPath -Encoding UTF8

$Query = ""
foreach ($str in $SiteOptions){
    $OptionName = $str.Split("")[0]

    try {
        $OptionValue = $str.Split("")[1]/1
    } catch {
        $OptionValue = $str.Split("")[1]
        $OptionValue = "'$OptionValue'"
    }

    $Query += "
IF EXISTS (SELECT * FROM [UniRu].Settings.SiteOptions
            WHERE Name = '$OptionName')
    UPDATE [UniRu].Settings.SiteOptions SET Value = $OptionValue
        WHERE Name = '$OptionName'
ELSE
    INSERT INTO [UniRu].Settings.SiteOptions (GroupId, Name, Value, IsInherited)
    VALUES (1, '$OptionName', $OptionValue, 0);  

--------------------------------------------------------------------------------          
    "

    # Invoke-Sqlcmd -Verbose -ServerInstance $env:COMPUTERNAME -Query $Query -ErrorAction continue
}

Set-Content -Path "C:\Users\enesudimov\Desktop\test.sql" -Encoding UTF8 -Value $Query