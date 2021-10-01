<#
    Generate-DeployScript
    Скрипт получает на вход имя сервиса и тип его развертывания (WebSite или Service).
    Создает шаблонный скрипт для развертывания какого-либо сервиса по пути C:\Users\$env:USERNAME\Desktop\
#>

Param (
    [Parameter(Mandatory=$true)]
    [string]$ServiceName,

    [Parameter(Mandatory=$true)]
    [ValidateSet("WebSite","Service")]
    [string]$ServiceType
)


$IisModules =
"Install-WindowsFeature web-mgmt-console
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Install-Module PowerShellGet -Force -Verbose
Install-Module -Name 'IISAdministration' -Verbose -Force
Import-Module IISAdministration
"


$RemoveOldServiceFunctionTemp =
"`t# Функция удаляет старую конфигурацию сервиса $ServiceName
`tparam (`$ServiceName)
`tWrite-Host -ForegroundColor Green `"[INFO] Remove old `$ServiceName configuration...`"
`t`$OldServiceNames = (Get-Service -Name *`$ServiceName* -ErrorAction SilentlyContinue).Name
`tforeach (`$OldServiceName in `$OldServiceNames)
`t{
`t    Stop-Service -Name `$OldServiceName -Verbose
`t    Write-Host -ForegroundColor Green `"[INFO] Remove old `$OldServiceName`"
`t    try {Remove-Service -Name `$OldServiceName -Verbose}
`t    catch {(Get-WmiObject win32_service -Filter `"name='`$OldServiceName'`").delete()} 
`t}"

$RemoveOldWebsiteFunctionTemp =
"`t# Функция удаляет старую конфигурацию вебсайта $ServiceName
`tparam (`$ServiceName)
`tif (Get-IISSite -Name `$ServiceName){Write-Host -ForegroundColor Green `"[INFO] Remove old `$ServiceName`"; Remove-IISSite -Name `$ServiceName -Confirm:`$false}
`t`$manager = Get-IISServerManager
`tif (Get-IISAppPool -Name `$ServiceName)
`t{
`t    Write-Host -ForegroundColor Green `"[INFO] Remove old `$ServiceName app pool`"
`t    `$manager.ApplicationPools[`$ServiceName].Delete()
`t    `$manager.CommitChanges()
`t}"

$SetupNewServiceFunctionTemp = 
"`t# Функция конфигурирует новый сервис $ServiceName
`tparam (
`t    `$ServiceName,
`t    `$ServiceFolderPath,
`t    `$ServiceUserName,
`t    [securestring]`$ServiceUserPassword
`t)
`t`$Credentials = New-Object System.Management.Automation.PSCredential (`$ServiceUserName, `$ServiceUserPassword)
`tWrite-Host -ForegroundColor Green `"[INFO] Deploy `$ServiceName as a Service`"
`ttry {& `"`$ServiceFolderPath\`$ServiceName.exe`" install;Get-Service -Name `"*`$ServiceName*`"}
`tcatch {New-Service -Name `$ServiceName -BinaryPathName `"`$ServiceFolderPath\`$ServiceName.exe`"}
`t`$Service = Get-Service -Name `"*`$ServiceName*`"
`tSet-Service -Name `$Service.Name -Credential `$Credentials -StartupType Automatic -Verbose
`tStart-Service -Name `$Service.Name"

$SetupNewWebSiteFunctionTemp = 
"`t# Функция конфигурирует новый вебсайт $ServiceName
`tparam (
`t    `$ServiceName,
`t    `$ServiceFolderPath,
`t    `$ServiceUserName,
`t    `$ServiceUserPassword,
`t    `$ManagedRuntimeVersion,
`t    `$BindingInformation,
`t    `$CertificateThumbPrint
`t)
`tWrite-Host -ForegroundColor Green `"[INFO] Deploy `$ServiceName as an IIS site`"
`t# Создание App Pool-а сервиса
`tWrite-Host -ForegroundColor Green `"[INFO] Create pool `$ServiceName...`"
`t`$manager = Get-IISServerManager
`t`$manager.ApplicationPools.Add(`$ServiceName)
`t`$manager.ApplicationPools[`$ServiceName].ManagedRuntimeVersion = `$ManagedRuntimeVersion
`t`$manager.ApplicationPools[`$ServiceName].ProcessModel.IdentityType = `"SpecificUser`"
`t`$manager.ApplicationPools[`$ServiceName].ProcessModel.UserName = `$ServiceUserName
`t`$manager.ApplicationPools[`$ServiceName].ProcessModel.Password = `$ServiceUserPassword
`t`$manager.CommitChanges()
`t#
`t# Создание сайта сервиса
`tWrite-Host -ForegroundColor Green `"[INFO] Create website `$ServiceName...`"
`tNew-IISSite -Name `$ServiceName -PhysicalPath `$ServiceFolderPath -Protocol https -BindingInformation `$BindingInformation -CertificateThumbPrint `$CertificateThumbPrint -CertStoreLocation `"Cert:\LocalMachine\My`" -Force
`t`$manager.Sites[`$ServiceName].Applications[`"/`"].ApplicationPoolName = `$ServiceName
`t`$manager.CommitChanges()"


$GeneratedScriptFileName = "Deploy-$ServiceName.ps1"
switch ($ServiceType)
{
    "WebSite" {
        $PathToParentFolder = "C:\inetpub"
        $RemoveOldServiceFunctionBody = $RemoveOldWebsiteFunctionTemp
        $SetupNewServiceFunctionBody = $SetupNewWebSiteFunctionTemp
        $PreDeploy = $IisModules
    }
    "Service" {
        $PathToParentFolder = "C:\Services"
        $RemoveOldServiceFunctionBody = $RemoveOldServiceFunctionTemp
        $SetupNewServiceFunctionBody = $SetupNewServiceFunctionTemp
        $PreDeploy = ""
    }
}


$TemplateScriptContent = 
"<#
    $ServiceName
    Скрипт для разворота $ServiceName. 
    Получает на вход параметр окружения Environment (строго TEST, STAGE, PROD).
    В зависимости от параметра окружения проставляет необходимые переменные для настройки сервиса
#>
Param (
    [Parameter(Mandatory=`$true)]
    [ValidateSet('TEST','STAGE','PROD')]
    [string]`$Environment = 'TEST'
)


function Remove-OldService
{
$RemoveOldServiceFunctionBody
}


function Deploy-NewService
{
$SetupNewServiceFunctionBody    
}


# Определение переменных в зависимости от выбранного окружения
switch (`$Environment)
{
    'PROD' {Write-Host 'Not complited. Run TEST env';exit}
    'STAGE' {Write-Host 'Not complited. Run TEST env';exit}
    'TEST' {
        `$ServiceName = `"$ServiceName`"
        `$ServiceFolderPath = `"$PathToParentFolder\`$ServiceName`"
        `$ServiceUserName = `"testkernel_svc@gkbaltbet.local`"
        `$ServiceUserPassword = ConvertTo-SecureString `"GldycLIFKM2018`" -AsPlainText -Force
        `$DataSource = `"localhost`"
        `$KernelDBInitialCatalog = `"BaltBetM`"
        `$KernelWebDBInitialCatalog = `"BaltBetWeb`"
    }
}


# Загрузка доп модулей
$PreDeploy # <--- писать тут --->
# 


# Удаление старой конфигурации
Remove-OldService -ServiceName `$ServiceName
# 


# Редактирование конфигов
Write-Host -ForegroundColor Green `"[INFO] Edit $ServiceName configuration files...`"
# <--- писать тут --->
#


# Настройка сервиса
Deploy-NewService -ServiceName `$ServiceName -ServiceFolderPath `$ServiceFolderPath -ServiceUserName `$ServiceUserName -ServiceUserPassword `$ServiceUserPassword # <-- указать праметры функции -->
# 
"


New-Item -Path "C:\Users\$env:USERNAME\Desktop\$GeneratedScriptFileName" -ItemType File -Value $TemplateScriptContent
$ScriptFullPath = (Get-Item -Path "C:\Users\$env:USERNAME\Desktop\$GeneratedScriptFileName").FullName
Write-Host -ForegroundColor Green "Создан новый скрипт: $ScriptFullPath"
