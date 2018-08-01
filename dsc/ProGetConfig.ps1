configuration ProGetConfig
{
    $domainCredential = Get-AutomationPSCredential -Name "DomainCredential"
    $proGetCredential = Get-AutomationPSCredential -Name "ProGetCredential"
    $installsDirectory = "C:\Installs"
    $proGetDownload = "https://inedo.com/proget/download/sql/5.1.6"
    $proGetInstaller = Join-Path $installsDirectory "ProGetSetup5.1.6.exe"

    Import-DscResource -ModuleName @{ModuleName = 'ComputerManagementDsc'; ModuleVersion = '5.1.0.0'}, 'PSDesiredStateConfiguration'

    Node $AllNodes.NodeName
    {
        Computer JoinDomain
        {
            Name       = $Node.NodeName
            DomainName = $Node.DomainName
            Credential = $domainCredential
        }

        WindowsFeature IIS {
            Ensure = "Present"
            Name   = "Web-Server"
        }
        
        WindowsFeature IISManagementTools {
            Ensure    = "Present"
            Name      = "Web-Mgmt-Tools"
            DependsOn = '[WindowsFeature]IIS'
        }

        WindowsFeature ASPNET {
            Ensure    = "Present"
            Name      = "Web-Asp-Net45"
            DependsOn = '[WindowsFeature]IIS'
        }        

        File InstallsDirectory {
            Ensure          = "Present"
            Type            = "Directory"
            DestinationPath = $installsDirectory
        }

        Script DownloadProGet {
            GetScript  = {
                @{
                    GetScript  = $GetScript
                    SetScript  = $SetScript
                    TestScript = $TestScript
                    Result     = ('True' -in (Test-Path $using:proGetInstaller))
                }
            }
            SetScript  = {
                Invoke-WebRequest -Uri $using:proGetDownload -OutFile $using:proGetInstaller
            }
            TestScript = {
                $Status = ('True' -in (Test-Path $using:proGetInstaller))
                $Status -eq $True
            }
            DependsOn  = "[File]InstallsDirectory"
        }

        Package ProGet {
            Ensure    = "Present"
            Name      = "ProGet"
            ProductId = "ProGet"
            Path      = $proGetInstaller
            Arguments = "/S /Edition=LicenseKey /LicenseKey=CH3J50AN-0HN8-P34RU4-J9V4EF-83JU9CVR /ConnectionString='Data Source=sqlserver01; Initial Catalog=ProGet; Integrated Security=True;' /Port=80 /UseIntegratedWebServer=false /UserAccount='$proGetCredential.UserName' /Password='$proGetCredential.Password' /ConfigureIIS /LogFile='C:\Installs\proget-install-log.txt'"
            DependsOn = "[Script]DownloadProGet"
        }
    }
}