configuration TfsAgentConfig
{
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
    }
}