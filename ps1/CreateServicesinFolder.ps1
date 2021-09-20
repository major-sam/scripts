$ServiceUserPassword = ConvertTo-SecureString -String "GldycLIFKM2018" -AsPlainText -Force
$ServiceUserName ="GKBALTBET\TestKernel_svc"
$credentials = New-Object System.Management.Automation.PSCredential ($ServiceUserName, $ServiceUserPassword)
$_baseDir = 'C:\Services\tt'
$servicesBin = @(get-childitem -Path $_baseDir -Recurse -Include *.exe |
  ? { $_.FullName -inotmatch 'client' -and $_.FullName -inotmatch 'aspnet' -and $_.FullName -inotmatch 'database'  -and $_.FullName -inotmatch 'api'})
###                                                                            ^  исключаем мусор через and^
write-host $servicesBin[0].Directory.Name
write-host $servicesBin[0].Name

foreach ($serviceBin in $servicesBin){
   sc.exe stop  $serviceBin.Directory.Name
   sc.exe delete  $serviceBin.Directory.Name
    $descr = $serviceBin.Directory.Name.Split(".")[-1]
    $params = @{
      Name = $serviceBin.Directory.Name
      BinaryPathName = $serviceBin.fullName
      DisplayName = $serviceBin.Directory.Name
      StartupType = "Automatic"
      Description = "This is a $descr service."
      Credential = $credentials
    }

    New-Service @params
}
