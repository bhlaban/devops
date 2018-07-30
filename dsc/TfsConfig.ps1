configuration TfsConfig
{
    $domainCredential = Get-AutomationPSCredential -Name "DomainCredential"
    $tfsDownload = "https://go.microsoft.com/fwlink/?LinkId=856344"
    $installsDirectory = "C:\Installs"
    $tfsInstallFile = Join-Path $installsDirectory "tfs-install.exe"
    $tfsInstallLog = Join-Path $installsDirectory "tfs-install-log.txt"
    $tfsConfigExe = "C:\Program Files\Microsoft Team Foundation Server 2018\Tools\TfsConfig.exe"

    Import-DscResource -ModuleName @{ModuleName='ComputerManagementDsc';ModuleVersion='5.1.0.0'},'PSDesiredStateConfiguration'

    Node localhost
    {
        Computer JoinDomain
        {
            Name = $Node.NodeName
            DomainName = $Node.DomainName
            Credential = $domainCredential
        }

        File InstallsDirectory {
            Ensure = "Present"
            Type = "Directory"
            DestinationPath = $installsDirectory
        }

        Script DownloadTFS {
            GetScript = {
                @{
                    GetScript = $GetScript
                    SetScript = $SetScript
                    TestScript = $TestScript
                    Result = ('True' -in (Test-Path $using:tfsInstallFile))
                }
            }
            SetScript = {
                Invoke-WebRequest -Uri $using:tfsDownload -OutFile $using:tfsInstallFile
            }
            TestScript = {
                $Status = ('True' -in (Test-Path $using:tfsInstallFile))
                $Status -eq $True
            }
            DependsOn = "[File]InstallsDirectory"
        }

        Script InstallTFS
        {
            GetScript = { 
                @{
                    GetScript = $GetScript
                    SetScript = $SetScript
                    TestScript = $TestScript
                    Result = ('True' -in (Test-Path $using:tfsConfigExe))
                }
            }
            SetScript = {
                $cmd = $using:tfsInstaller + " /full /quiet /Log $using:tfsInstallLog"
                Invoke-Expression $cmd | Write-Verbose
                #Sleep for 10 seconds to make sure installer is going
                Start-Sleep -s 10
                #The tfs installer will per default run in the background. We will wait for it. 
                Wait-Process -Name "tfs_installer"
            }
            TestScript = {
                Test-Path $using:tfsConfigExe
            }
            DependsOn = "[Script]DownloadTFS"
        }
    }
}