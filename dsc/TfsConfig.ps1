configuration TfsConfig
{
    $domainCredential = Get-AutomationPSCredential -Name "DomainCredential"
    $tfsDownload = "https://go.microsoft.com/fwlink/?LinkId=856344"
    $installsDirectory = "C:\Installs"
    $tfsInstaller = Join-Path $installsDirectory "tfs-installer.exe"

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
                    Result = ('True' -in (Test-Path $using:tfsInstaller))
                }
            }
            SetScript = {
                Invoke-WebRequest -Uri $using:tfsDownload -OutFile $using:tfsInstaller
            }
            TestScript = {
                $Status = ('True' -in (Test-Path $using:tfsInstaller))
                $Status -eq $True
            }
            DependsOn = "[File]InstallsDirectory"
        }
    }
}