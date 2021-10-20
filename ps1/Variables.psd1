<# 
    Файл содержит:
    - VmInfo - массив словарей, содержащих данные машины
        - VmName - имя машины
        - ShortName - Короткое имя машины, используемое при запуске скрипта run.ps1
        - ShortDomainName - Короткое имя машины используемое для домена bb-webapps.com

    - DbInfo - массив словарей, содержащих данные для восстанавливаемых БД
        - DbName - Имя восстанавливаемой БД на SqlServer
        - BackupFile - Название бэкап файла, который будет применен к БД DbName
        - RelocateFiles - массив словарей, содержащих информацию в какие файлы производить запись при восстановлении из бэкапа (в SQL менеджере смотреть вкладку Файлы в окне восстановления)
            - SourceName - Логическое имя файла БД
            - FileName - Физическое имя файла, в который будет произведено восстановление
    
    - ReleaseFolder - Путь до папки актуализации. Получаем от Толи 

    - DefaultServicesFolder - Стандартная директория для сервисов на целевой машине

    - DefaultWebSitesFolder - Стандартная директория для сайтов на целевой машине

    - DefaultUserName - Стандартный юзер, от которого запускаются все сервисы (сейчас testkernel_svc, далее поменяем на gMSA юзера)

    - DefaultUserPassword - Пароль стандартного юзера (GldycLIFKM2018)
    
    - DefaultCertificateThumbPrint - Стандартный сертификат, который вешается на все сервисы (сейчас bb-webapps.com, скоро протухнет)
#>
@{
    VmInfo = @(
        @{
            VmName = "VM1APKTEST-P0"
            ShortName = "VM1"
            ShortDomainName = "vm1-p0"
        }
        @{
            VmName = "VM2APKTEST-P0"
            ShortName = "VM2"
            ShortDomainName = "vm2-p0"
        }
        @{
            VmName = "VM3APKTEST-P0"
            ShortName = "VM3"
            ShortDomainName = "vm3-p0"
        }
        @{
            VmName = "VM4APKTEST-P0"
            ShortName = "VM4"
            ShortDomainName = "vm4-p0"
        }
        @{
            VmName = "VM5APKTEST-P0"
            ShortName = "VM5"
            ShortDomainName = "vm5-p0"
        }
        @{
            VmName = "VM1APKTEST-P3"
            ShortName = "VM6"
            ShortDomainName = "vm1-p3"
        }
        @{
            VmName = "VM2APKTEST-P3"
            ShortName = "VM7"
            ShortDomainName = "vm2-p3"
        }
        @{
            VmName = "VM3APKTEST-P3"
            ShortName = "VM8"
            ShortDomainName = "vm3-p3"
        }
        @{
            VmName = "VM4APKTEST-P3"
            ShortName = "VM9"
            ShortDomainName = "vm4-p3"
        }
        @{
            VmName = "VM5APKTEST-P3"
            ShortName = "VM10"
            ShortDomainName = "vm5-p3"
        }
        @{
            VmName = "VM-HM1-WS1"
            ShortName = "VM11"
            ShortDomainName = "ws1-hm1"
        }
        @{
            VmName = "VM-HM1-WS2"
            ShortName = "VM12"
            ShortDomainName = "ws2-hm1"
        }
        @{
            VmName = "VM-HM1-WS3"
            ShortName = "VM13"
            ShortDomainName = "ws3-hm1"
        }
        @{
            VmName = "VM-HM1-WS4"
            ShortName = "VM14"
            ShortDomainName = "ws4-hm1"
        }
        @{
            VmName = "VM-HM1-WS5"
            ShortName = "VM15"
            ShortDomainName = "ws5-hm1"
        }
        @{
            VmName = "VM-HM1-WS6"
            ShortName = "VM16"
            ShortDomainName = "ws6-hm1"
        }
        @{
            VmName = "VM-N1-WS1"
            ShortName = "VM17"
            ShortDomainName = "ws1-n1"
        }
        @{
            VmName = "VM-N1-WS2"
            ShortName = "VM18"
            ShortDomainName = "ws2-n1"
        }
        @{
            VmName = "VM-N1-WS3"
            ShortName = "VM19"
            ShortDomainName = "ws3-n1"
        }
        @{
            VmName = "VM-N1-WS4"
            ShortName = "VM20"
            ShortDomainName = "ws4-n1"
        }
        @{
            VmName = "VM-N1-WS5"
            ShortName = "VM21"
            ShortDomainName = "ws5-n1"
        }
        @{
            VmName = "VM-N1-WS6"
            ShortName = "VM22"
            ShortDomainName = "ws6-n1"
        }
        @{
            VmName = "VM-N1-WS7"
            ShortName = "VM23"
            ShortDomainName = "ws7-n1"
        }
        @{
            VmName = "VM1APKTEST-P1"
            ShortName = "ST1"
            ShortDomainName = "st1"
        }
        @{
            VmName = "VM-P1-WS2"
            ShortName = "ST2"
            ShortDomainName = "st2"
        }
        @{
            VmName = "VM-P1-WS4"
            ShortName = "ST3"
            ShortDomainName = "st3"
        }
        @{
            VmName = "VM-P1-WS5"
            ShortName = "ST4"
            ShortDomainName = "st4"
        }
        @{
            VmName = "VM-N7-WS4"
            ShortName = "ST-TT"
            ShortDomainName = "st-tt"
        }
    )
    DbInfo = @(
	    @{
	    	DbName = "BaltBetM"
	    	BackupFile = "BaltBetM.bak"
	    	RelocateFiles = @(
	    		@{
	    			SourceName = "BaltBetM"
	    			FileName = "BaltBetM.mdf"
	    		}
	    		@{
	    			SourceName = "CoefFileGroup"
	    			FileName = "CoefFileGroup.mdf"
	    		}
	    		@{
	    			SourceName = "BaltBet"
	    			FileName = "BaltBet.ldf"
	    		}
	    	)
	    }
	    @{
	    	DbName = "BaltBetMMirror"
	    	BackupFile = "BaltBetM.bak"
	    	RelocateFiles = @(
	    		@{
	    			SourceName = "BaltBetM"
	    			FileName = "BaltBetMMirror.mdf"
	    		}
	    		@{
	    			SourceName = "CoefFileGroup"
	    			FileName = "CoefFileGroupMirror.mdf"
	    		}
	    		@{
	    			SourceName = "BaltBet"
	    			FileName = "BaltBetMirror.ldf"
	    		}
	    	)
	    }
	    @{
	    	DbName = "BaltBetWeb"
	    	BackupFile = "BaltBetWeb.bak"
	    	RelocateFiles = @(
	    		@{
	    			SourceName = "BaltBetWeb"
	    			FileName = "BaltBetWeb.mdf"
	    		}
	    		@{
	    			SourceName = "Files"
	    			FileName = "Files"
	    		}
	    		@{
	    			SourceName = "BaltBetWeb_log"
	    			FileName = "BaltBetWeb.ldf"
	    		}
	    	)
	    }
	    <#@{
	    	DbName = "ParserNew"
	    	BackupFile = "parser.bak"
	    	RelocateFiles = @(
	    		@{
	    			SourceName = "ParserNew"
	    			FileName = "ParserNew.mdf"
	    		}
	    		@{
	    			SourceName = "ParserNew_log"
	    			FileName = "ParserNew_log.ldf"
	    		}
	    	)
	    } #>
    )
    ReleaseFolder = ""
    DefaultServicesFolder = "C:\Services"
    DefaultWebSitesFolder = "C:\inetpub" 
    DefaultUserName = "testkernel_svc@gkbaltbet.local"
    DefaultUserPassword = "GldycLIFKM2018"
    DefaultCertificateThumbPrint = "84195e81971d98b8b7caa4728d2fcc5612197bb6"   
    DefaultIdentityType = "SpecificUser"
}


 