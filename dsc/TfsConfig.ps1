configuration TfsConfig
{
    $domainCredential = Get-AutomationPSCredential -Name "DomainCredential"

    Import-DscResource -ModuleName @{ModuleName='ComputerManagementDsc';ModuleVersion='5.1.0.0'},'PSDesiredStateConfiguration'

    $downloadLink = "https://go.microsoft.com/fwlink/?LinkId=856344"
    $installerDownload = $env:TEMP + "\tfs_installer.exe"

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
                Write-Host "Downloading TFS: " + $using:downloadLink
                Invoke-WebRequest -Uri $using:downloadLink -OutFile $using:installerDownload
            }
            TestScript = {
                Test-Path $using:installerDownload
            }
			DependsOn = "[Computer]JoinDomain"
        }
    }
}