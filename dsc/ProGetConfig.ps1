configuration ProGetConfig
{
    Import-DscResource -ModuleName 'ComputerManagementDsc'
    Import-DscResource -ModuleName 'PSDesiredStateConfiguration'
    Import-DscResource -ModuleName 'xWebAdministration'

    $domainCredential = Get-AutomationPSCredential -Name "DomainCredential"
    $proGetCredential = Get-AutomationPSCredential -Name "ProGetCredential"
    $installsDirectory = "C:\Installs"
    $proGetDownload = "https://inedo.com/proget/download/sql/5.1.6"
    $proGetInstaller = Join-Path $installsDirectory "ProGetSetup5.1.6.exe"

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

        xWebsite StopDefaultSite
        {
            Ensure          = 'Present'
            Name            = 'Default Web Site'
            State           = 'Stopped'
            PhysicalPath    = 'C:\inetpub\wwwroot'
            DependsOn       = '[WindowsFeature]IIS'
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
    }
}