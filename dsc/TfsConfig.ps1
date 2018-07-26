configuration TfsConfig
{
    $tfsDownloadLinks = @{
        "TFS2018" = "https://go.microsoft.com/fwlink/?LinkId=856344"
        "TFS2017Update2" = "https://go.microsoft.com/fwlink/?LinkId=850949"
        "TFS2017Update3" = "https://go.microsoft.com/fwlink/?LinkId=857134"
    }
    $tfsVersion = "TFS2018"
    $tfsDownloadLink = $tfsDownloadLinks[$tfsVersion]
    $tfsInstaller = $env:TEMP + "\tfs_installer.exe"

    $domainCredential = Get-AutomationPSCredential -Name "DomainCredential"

    Import-DscResource -ModuleName @{ModuleName='ComputerManagementDsc';ModuleVersion='5.1.0.0'},'PSDesiredStateConfiguration'

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
                Write-Host "Downloading TFS: " + $using:tfsDownloadLink
                Invoke-WebRequest -Uri $using:tfsDownloadLink -OutFile $using:tfsInstaller
            }
            TestScript = {
                Test-Path $using:tfsInstaller
            }
			DependsOn = "[Computer]JoinDomain"
        }
    }
}