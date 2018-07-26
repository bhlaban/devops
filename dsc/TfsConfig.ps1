configuration TfsConfig
{
    $domainCredential = Get-AutomationPSCredential -Name "DomainCredential"

    Import-DscResource -ModuleName @{ModuleName='ComputerManagementDsc';ModuleVersion='5.1.0.0'},'PSDesiredStateConfiguration'

    $tfsDownload = "https://go.microsoft.com/fwlink/?LinkId=856344"
    $tfsInstaller = $env:TEMP + "\tfs_installer.exe"

    Node $AllNodes.NodeName
    {
        Computer JoinDomain
        {
            Name = $Node.NodeName
            DomainName = $Node.DomainName
            Credential = $domainCredential
        }

        Script DownloadTFS
        {
            GetScript = {
                return @{ 'Result' = $true }
            }
            SetScript = {
                Write-Host "Downloading TFS: " + $tfsInstaller
                $webClient = New-Object System.Net.WebClient
                $webClient.DownloadFile($tfsDownload, $tfsInstaller)
            }
            TestScript = {
                Test-Path $tfsInstaller
            }
			DependsOn = "[Computer]JoinDomain"
        }
    }
}