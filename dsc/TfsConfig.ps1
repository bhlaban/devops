configuration TfsConfig
{
    Import-DscResource -ModuleName 'ComputerManagementDsc'
    Import-DscResource -ModuleName 'PSDesiredStateConfiguration'
    Import-DscResource -ModuleName 'xPendingReboot'
    Import-DscResource -ModuleName 'xWebAdministration'

    $domainCredential = Get-AutomationPSCredential -Name "DomainCredential"
    $tfsDownload = "https://go.microsoft.com/fwlink/?LinkId=856344"
    $installsDirectory = "C:\Installs"
    $tfsInstallFile = Join-Path $installsDirectory "tfs-install.exe"
    $tfsInstallLog = Join-Path $installsDirectory "tfs-install-log.txt"
    $tfsConfigExe = "C:\Program Files\Microsoft Team Foundation Server 2018\Tools\TfsConfig.exe"

    Node localhost
    {
        LocalConfigurationManager{
            RebootNodeIfNeeded = $True
        }

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

        Script DownloadTFS {
            GetScript  = {
                @{
                    GetScript  = $GetScript
                    SetScript  = $SetScript
                    TestScript = $TestScript
                    Result     = ('True' -in (Test-Path $using:tfsInstallFile))
                }
            }
            SetScript  = {
                Invoke-WebRequest -Uri $using:tfsDownload -OutFile $using:tfsInstallFile
            }
            TestScript = {
                $Status = ('True' -in (Test-Path $using:tfsInstallFile))
                $Status -eq $True
            }
            DependsOn  = "[File]InstallsDirectory"
        }

        Script InstallTFS {
            GetScript  = { 
                @{
                    GetScript  = $GetScript
                    SetScript  = $SetScript
                    TestScript = $TestScript
                    Result     = ('True' -in (Test-Path $using:tfsConfigExe))
                }
            }
            SetScript  = {
                $cmd = $using:tfsInstallFile + " /full /quiet /Log $using:tfsInstallLog"
                Invoke-Expression $cmd | Write-Verbose
                Start-Sleep -s 10
                Wait-Process -Name "tfs_installer"
            }
            TestScript = {
                Test-Path $using:tfsConfigExe
            }
            DependsOn  = "[Script]DownloadTFS"
        }

        xPendingReboot PostInstallReboot {
            Name = "Check for a pending reboot before changing anything"
            DependsOn = "[Script]InstallTFS"
        }

        Script ConfigureTFS
        {
            GetScript = {
                @{
                    GetScript  = $GetScript
                    SetScript  = $SetScript
                    TestScript = $TestScript
                    Result     = ('True' -in (Test-Path $using:tfsConfigExe))
                }                
            }
            SetScript = {
                $sqlServerInstance = "sqlserver01.devops.local"
                $siteBindings = "https:*:443:tfs01.devops.local:My:generate,http:*:80:"
                $cmd = "& '$using:tfsConfigExe' unattend /configure /continue /type:NewServerAdvanced /inputs:SqlInstance=$sqlServerInstance;SiteBindings='$siteBindings'"
                Invoke-Expression $cmd | Write-Verbose
            }
            TestScript = {
                $sites = Get-WebBinding | Where-Object {$_.bindingInformation -like "*tfs*" }
                -not [String]::IsNullOrEmpty($sites)
            }
            DependsOn = "[xPendingReboot]PostInstallReboot","[xWebsite]StopDefaultSite"
        }
    }
}