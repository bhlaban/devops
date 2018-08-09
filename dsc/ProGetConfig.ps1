configuration ProGetConfig
{
    param
    (
        [Parameter(Mandatory)]
        [string]$DownloadUrl,

        [Parameter(Mandatory)]
        [string]$LicenseKey,

        [Parameter(Mandatory)]
        [string]$SqlServerInstance
    )

    Import-DscResource -ModuleName 'ComputerManagementDsc'
    Import-DscResource -ModuleName 'PSDesiredStateConfiguration'
    Import-DscResource -ModuleName 'xWebAdministration'

    $domainCredential = Get-AutomationPSCredential -Name "DomainCredential"
    $installsDirectory = "C:\Installs"
    $proGetInstaller = Join-Path $installsDirectory "ProGetSetup.exe"
    $proGetWebConfig = "C:\Program Files\ProGet\WebApp\web.config"

    Node $AllNodes.NodeName
    {
        Computer JoinDomain
        {
            Name = $Node.NodeName
            DomainName = $Node.DomainName
            Credential = $domainCredential
        }

        WindowsFeature IIS {
            Ensure = "Present"
            Name = "Web-Server"
        }

        WindowsFeature IISManagementTools {
            Ensure = "Present"
            Name = "Web-Mgmt-Tools"
            DependsOn = '[WindowsFeature]IIS'
        }

        WindowsFeature ASPNET {
            Ensure = "Present"
            Name = "Web-Asp-Net45"
            DependsOn = '[WindowsFeature]IIS'
        }

        xWebsite StopDefaultSite
        {
            Ensure = 'Present'
            Name = 'Default Web Site'
            State = 'Stopped'
            PhysicalPath = 'C:\inetpub\wwwroot'
            DependsOn = '[WindowsFeature]IIS'
        }

        File InstallsDirectory {
            Ensure = "Present"
            Type = "Directory"
            DestinationPath = $installsDirectory
        }

        Script DownloadProGet {
            GetScript = {
                return @{ 'Result' = $true }
            }
            SetScript = {
                Invoke-WebRequest -Uri $using:DownloadUrl -OutFile $using:proGetInstaller
            }
            TestScript = {
                Test-Path $using:proGetInstaller
            }
            DependsOn = "[File]InstallsDirectory"
        }

        Script InstallProGet {
            GetScript = { 
                return @{ 'Result' = $true }
            }
            SetScript = {
                a$cmd = "& '$using:proGetInstaller' /S /Edition=LicenseKey /LicenseKey=$using:LicenseKey /ConnectionString='Data Source=$using:SqlServerInstance; Initial Catalog=proget; Integrated Security=True;' /Port=80 /UseIntegratedWebServer=false /UserAccount='seicdevops\proget' /Password='P@`$`$word12345' /ConfigureIIS /LogFile='C:\Installs\proget-install-log.txt'"
                Invoke-Expression $cmd | Write-Verbose
            }
            TestScript = {
                Test-Path $using:proGetWebConfig
            }
            PsDscRunAsCredential = $domainCredential
            DependsOn = "[Script]DownloadProGet"
        }
    }
}