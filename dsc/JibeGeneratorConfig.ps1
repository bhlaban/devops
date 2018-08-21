configuration JibeGeneratoreConfig
{
    Import-DscResource -ModuleName 'ComputerManagementDsc'
    Import-DscResource -ModuleName 'PSDesiredStateConfiguration'
    Import-DscResource -ModuleName 'xWebAdministration'

    $domainCredential = Get-AutomationPSCredential -Name "DomainCredential"

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
    }
}