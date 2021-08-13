<#
Скрипт для равертывания нового релиза
powershell.exe -file "\\server\tcbuild$\Testers\_VM Update Instructions\06.08.2021 RELEASE\06.08.2021 RELEASE.ps1"
#>

function Format-Json {
    <#
    .SYNOPSIS
        Prettifies JSON output.
    .DESCRIPTION
        Reformats a JSON string so the output looks better than what ConvertTo-Json outputs.
    .PARAMETER Json
        Required: [string] The JSON text to prettify.
    .PARAMETER Minify
        Optional: Returns the json string compressed.
    .PARAMETER Indentation
        Optional: The number of spaces (1..1024) to use for indentation. Defaults to 4.
    .PARAMETER AsArray
        Optional: If set, the output will be in the form of a string array, otherwise a single string is output.
    .EXAMPLE
        $json | ConvertTo-Json  | Format-Json -Indentation 2
    #>
    [CmdletBinding(DefaultParameterSetName = 'Prettify')]
    Param(
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [string]$Json,

        [Parameter(ParameterSetName = 'Minify')]
        [switch]$Minify,

        [Parameter(ParameterSetName = 'Prettify')]
        [ValidateRange(1, 1024)]
        [int]$Indentation = 4,

        [Parameter(ParameterSetName = 'Prettify')]
        [switch]$AsArray
    )

    if ($PSCmdlet.ParameterSetName -eq 'Minify') {
        return ($Json | ConvertFrom-Json) | ConvertTo-Json -Depth 100 -Compress
    }

    # If the input JSON text has been created with ConvertTo-Json -Compress
    # then we first need to reconvert it without compression
    if ($Json -notmatch '\r?\n') {
        $Json = ($Json | ConvertFrom-Json) | ConvertTo-Json -Depth 100
    }

    $indent = 0
    $regexUnlessQuoted = '(?=([^"]*"[^"]*")*[^"]*$)'

    $result = $Json -split '\r?\n' |
        ForEach-Object {
            # If the line contains a ] or } character, 
            # we need to decrement the indentation level unless it is inside quotes.
            if ($_ -match "[}\]]$regexUnlessQuoted") {
                $indent = [Math]::Max($indent - $Indentation, 0)
            }

            # Replace all colon-space combinations by ": " unless it is inside quotes.
            $line = (' ' * $indent) + ($_.TrimStart() -replace ":\s+$regexUnlessQuoted", ': ')

            # If the line contains a [ or { character, 
            # we need to increment the indentation level unless it is inside quotes.
            if ($_ -match "[\{\[]$regexUnlessQuoted") {
                $indent += $Indentation
            }

            $line
        }

    if ($AsArray) { return $result }
    return $result -Join [Environment]::NewLine
}


$pathtojson = "C:\inetpub\AdminMessageService\appsettings.json"
$json_appsetings = Get-Content -Raw -path $pathtojson | ConvertFrom-Json 
$realm  = ($json_appsetings.Authorization.Realm).toLower()
$json_appsetings.Authorization.Realm = $realm
ConvertTo-Json   $json_appsetings -Depth 4  | Format-Json | Set-Content $pathtojson -Encoding UTF8

$webConfig = "C:\inetpub\ClientWorkSpace\Web.config"
$doc = [Xml](Get-Content $webConfig)
#edit configuration.appSettings.IdentificationServiceAddress value
$obj = $doc.configuration.appSettings.add | where {$_.Key -eq 'EmulateCard' }
$obj.value = "8BA5D61B"
$doc.Save($webConfig)

$dbname = "BaltBetM"
$KillConnectionsSql=
"
USE master
GO
ALTER DATABASE [$dbname] SET SINGLE_USER WITH ROLLBACK IMMEDIATE

GO
DROP DATABASE [$dbname]
GO
"
## Дропаем старую БД $dbname
Invoke-Sqlcmd -Verbose -ServerInstance $env:COMPUTERNAME -Query $KillConnectionsSql -ErrorAction continue
# Разворачиваем базу $dbname  
$fullbkupfile = "\\server\tcbuild$\Testers\_VM Update Instructions\06.08.2021 RELEASE\_Full DB Restoration\BaltBetM.bak"
$RelocateData = New-Object Microsoft.SqlServer.Management.Smo.RelocateFile("BaltBetM", "C:\Program Files\Microsoft SQL Server\MSSQL12.MSSQLSERVER\MSSQL\DATA\$dbname.mdf")
$RelocateData2  = New-Object Microsoft.SqlServer.Management.Smo.RelocateFile("CoefFileGroup", "C:\Program Files\Microsoft SQL Server\MSSQL12.MSSQLSERVER\MSSQL\DATA\CoefFileGroup.mdf")
$RelocateLog  = New-Object Microsoft.SqlServer.Management.Smo.RelocateFile("BaltBet", "C:\Program Files\Microsoft SQL Server\MSSQL12.MSSQLSERVER\MSSQL\DATA\$dbname.ldf")
Restore-SqlDatabase -Verbose -ServerInstance $env:COMPUTERNAME -Database $dbname -BackupFile  $fullbkupfile -RelocateFile @($RelocateData,$RelocateData2,$RelocateLog) -ReplaceDatabase


$tmp_folder = "c:\temp_dev"
Remove-Item -Recurse -Force  $tmp_folder
$db = "BaltBetM"
$excludeSqlCmds = @("1.DBRestore.sql","*CreateEvents*")
$queryTimeout = 720
mkdir $tmp_folder 
Copy-Item  -path "Microsoft.PowerShell.Core\FileSystem::\\server\tcbuild$\Testers\_VM Update Instructions\06.08.2021 RELEASE\_Full DB Restoration\*" -include  "*.sql" -Recurse -Destination $tmp_folder -exclude $excludeSqlCmds
$files = Get-ChildItem -path "c:\temp_dev\*" -Include "*.sql" -exclude $excludeSqlCmds
try {
    foreach ($file in $files) {
        Write-Host -ForegroundColor Gray "EXECUTED STARETED: " $file
        Invoke-Sqlcmd -verbose -QueryTimeout $queryTimeout -ServerInstance $env:COMPUTERNAME -Database $db -InputFile $file -ErrorAction continue
        Write-Host -ForegroundColor Green "EXECUTED SUCCESSFULLY: " $file 
    }
}
catch {
 Write-Host -ForegroundColor RED "FAILED TO EXECUTE: " $file
}
Push-Location -Path $env:USERPROFILE
Remove-Item -Recurse -Force  $tmp_folder
