Param (
    [Parameter(Mandatory=$true)]
    $User,

    [Parameter(Mandatory=$true)]
    [ValidateSet(
        "db_accessadmin",
        "db_backupoperator",
        "db_datareader",
        "db_datawriter",
        "db_ddladmin",
        "db_denydatawriter",
        "db_owner",
        "db_securityadmin",
        "public"
    )]
    $DBRoleMembership    
)

$DataBases = Invoke-Sqlcmd -Database master -ServerInstance localhost -Query {
    SELECT name FROM sys.databases
	WHERE name != 'master' 
	AND name != 'tempdb'
	AND name != 'model'
	AND name != 'msdb'
}

$CreateLoginQwr = 
"IF NOT EXISTS (select name from sysusers WHERE name = '$User')   
BEGIN
    CREATE LOGIN [$User] FROM WINDOWS WITH DEFAULT_DATABASE=[master]
END
"
Invoke-Sqlcmd -ServerInstance localhost -Query $CreateLoginQwr


foreach ($DataBase in $DataBases.Name)
{
    $qwr = "
    USE [$DataBase]
    GO
    ALTER ROLE [$DBRoleMembership] ADD MEMBER [$User]
    GO
    " 

    Invoke-Sqlcmd -ServerInstance localhost -Query $qwr
}

$ConnectQwr = 
"USE [master]
GO
GRANT CONNECT ANY DATABASE TO [$User]
GO
"
Invoke-Sqlcmd -ServerInstance localhost -Query $ConnectQwr
