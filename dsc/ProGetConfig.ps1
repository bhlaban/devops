configuration ProGetConfig
{
    $domainCredential = Get-AutomationPSCredential -Name "DomainCredential"
    $installsDirectory = "C:\Installs"
    $proGetDownload = "https://inedo.com/proget/download/sql/5.1.6"
    $proGetInstaller = Join-Path $installsDirectory "ProGetSetup5.1.6.exe"

    Import-DscResource -ModuleName @{ModuleName='ComputerManagementDsc';ModuleVersion='5.1.0.0'},'PSDesiredStateConfiguration'

    Node $AllNodes.NodeName
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

        Script DownloadProGet {
            GetScript = {
                @{
                    GetScript = $GetScript
                    SetScript = $SetScript
                    TestScript = $TestScript
                    Result = ('True' -in (Test-Path $using:proGetInstaller))
                }
            }
            SetScript = {
                Invoke-WebRequest -Uri $using:proGetDownload -OutFile $using:proGetInstaller
            }
            TestScript = {
                $Status = ('True' -in (Test-Path $using:proGetInstaller))
                $Status -eq $True
            }
            DependsOn = "[File]InstallsDirectory"
        }
    }
}