configuration DomainControllerConfig
{
    $domainCredential = Get-AutomationPSCredential domainCredential

    Import-DscResource -ModuleName @{ModuleName='xActiveDirectory';ModuleVersion='2.16.0.0'},@{ModuleName='xNetworking';ModuleVersion='5.7.0.0'},@{ModuleName='xStorage';ModuleVersion='3.2.0.0'},'PSDesiredStateConfiguration'

    Node $AllNodes.NodeName
    {
        xWaitforDisk Disk2
        {
             DiskId = 2
             RetryIntervalSec = 10
             RetryCount = 30
        }

        xDisk DiskF
        {
             DiskId = 2
             DriveLetter = 'F'
        }

        WindowsFeature DNS
        {
            Ensure = "Present"
            Name = "DNS"
        }

        WindowsFeature DNS-Tools
        {
            Ensure = "Present"
            Name = "RSAT-DNS-Server"
            DependsOn = "[WindowsFeature]DNS"
        }

        xDnsServerAddress DnsServerAddress
        {
            Address = $Node.DnsIpAddress
            InterfaceAlias = $Node.NicAlias
            AddressFamily = 'IPv4'
            DependsOn = "[WindowsFeature]DNS"
        }

        WindowsFeature ADDS
        {
            Ensure = 'Present'
            Name = 'AD-Domain-Services'
        }
        
        WindowsFeature ADDS-Tools
        {
            Ensure = "Present"
            Name = "RSAT-ADDS-Tools"
            DependsOn = "[WindowsFeature]ADDS"
        }

        WindowsFeature AD-AdminCenter
        {
            Ensure = "Present"
            Name = "RSAT-AD-AdminCenter"
            DependsOn = "[WindowsFeature]ADDS-Tools"
        }
        
        xADDomain Domain
        {
            DomainName = $Node.DomainName
            DomainAdministratorCredential = $domainCredential
            SafemodeAdministratorPassword = $domainCredential
            DatabasePath = 'F:\NTDS'
            LogPath = 'F:\NTDS'
            SysvolPath = 'F:\SYSVOL'
            DependsOn = '[WindowsFeature]ADDSInstall'
        }
   }
}