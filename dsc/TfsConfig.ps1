configuration TfsConfig
{
    $domainCredential = Get-AutomationPSCredential -Name "DomainCredential"

    Import-DscResource -ModuleName @{ModuleName = 'ComputerManagementDsc'; ModuleVersion = '5.1.0.0'}, 'PSDesiredStateConfiguration'

    Node $AllNodes.NodeName
    {
        Computer JoinDomain {
            Name       = $Node.NodeName
            DomainName = $Node.DomainName
            Credential = $domainCredential
        }

        Script DownloadTFS {
            GetScript = {
                @{
                    GetScript = $GetScript
                    SetScript = $SetScript
                    TestScript = $TestScript
                    Result = ('True' -in (Test-Path C:\Installs\tfs-install.msi))
                }
            }
            SetScript = {
                Invoke-WebRequest -Uri "https://go.microsoft.com/fwlink/?LinkId=856344" -OutFile "C:\Installs\tfs-install.msi"
            }
            TestScript = {
                $Status = ('True' -in (Test-Path C:\Installs\tfs-install.msi))
                $Status -eq $True
            }
        }
    }
}