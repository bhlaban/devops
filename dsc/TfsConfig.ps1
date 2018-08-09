configuration TfsConfig
{
    Import-DscResource -ModuleName 'ComputerManagementDsc'
    Import-DscResource -ModuleName 'PSDesiredStateConfiguration'
    Import-DscResource -ModuleName 'xPendingReboot'
    Import-DscResource -ModuleName 'xWebAdministration'

    $domainCredential = Get-AutomationPSCredential -Name "DomainCredential"
    $globalSiteName = "tfs"
    $installsDirectory = "C:\Installs"
    $isPrimaryInstance = $true
    $sslThumbprint = "generate"
    $sqlServerInstance = "sqlserver01"
    $tfsDownload = "https://go.microsoft.com/fwlink/?LinkId=856344"
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
            Name = $Node.NodeName
            DomainName = $Node.DomainName
            Credential = $domainCredential
        }

        WindowsFeature IIS {
            Ensure = "Present"
            Name = "Web-Server"
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

        Script DownloadTFS {
            GetScript = {
                return @{ 'Result' = $true }
            }
            SetScript = {
                Invoke-WebRequest -Uri $using:tfsDownload -OutFile $using:tfsInstallFile
            }
            TestScript = {
                Test-Path $using:tfsInstallFile
            }
            DependsOn = "[File]InstallsDirectory"
        }

        Script InstallTFS {
            GetScript = { 
                return @{ 'Result' = $true }
            }
            SetScript = {
                $cmd = $using:tfsInstallFile + " /full /quiet /Log $using:tfsInstallLog"
                Invoke-Expression $cmd | Write-Verbose
                Start-Sleep -s 10
                Wait-Process -Name "tfs_installer"
            }
            TestScript = {
                Test-Path $using:tfsConfigExe
            }
            DependsOn = "[Script]DownloadTFS"
        }

        xPendingReboot PostInstallReboot {
            Name = "Check for a pending reboot before changing anything"
            DependsOn = "[Script]InstallTFS"
        }

        Script ConfigureTFS
        {
            GetScript = {
                return @{ 'Result' = $true }               
            }
            SetScript = {

                $siteBindings = "https:*:443:" + $using:hostName + "." + $using:Node.DomainName + ":My:" + $using:sslThumbprint

                if ($using:hostName -ne $using:globalSiteName) {
                    $siteBindings += ",https:*:443:" + $using:globalSiteName + "." + $using:Node.DomainName + ":My:" + $using:sslThumbprint
                }

                $siteBindings += ",http:*:80:"

                $publicUrl = "http://$using:hostName"

                $cmd = ""
                if ($using:isPrimaryInstance) {                
                    $cmd = "& '$using:tfsConfigExe' unattend /configure /continue /type:NewServerAdvanced  /inputs:WebSiteVDirName=';'PublicUrl=$publicUrl';'SqlInstance=$using:SqlServerInstance';'SiteBindings='$siteBindings'"
                } else {
                    $cmd = "& '$using:tfsConfigExe' unattend /configure /continue /type:ApplicationTierOnlyAdvanced  /inputs:WebSiteVDirName=';'PublicUrl=$publicUrl';'SqlInstance=$using:SqlServerInstance';'SiteBindings='$siteBindings'"
                }

                Write-Verbose "$cmd"
                Invoke-Expression $cmd | Write-Verbose

                $publicUrl = "https://$using:globalSiteName" + "." + $using:Node.DomainName
                $cmd = "& '$using:tfsConfigExe' settings /publicUrl:$publicUrl"
                Write-Verbose "$cmd"
                Invoke-Expression $cmd | Write-Verbose
            }
            TestScript = {
                $sites = Get-WebBinding | Where-Object {$_.bindingInformation -like "*tfs*" }
                -not [String]::IsNullOrEmpty($sites)
            }
            PsDscRunAsCredential = $domainCredential
            DependsOn = "[xPendingReboot]PostInstallReboot","[xWebsite]StopDefaultSite"
        }
    }
}