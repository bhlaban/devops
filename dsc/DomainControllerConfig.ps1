configuration DomainControllerConfig
{
    $domainCredential = Get-AutomationPSCredential domainCredential
    $firstNetAdapter = Get-NetAdapter | Where-Object Name -Like "Ethernet*" | Select-Object -First 1

    Import-DscResource -ModuleName @{ModuleName='xActiveDirectory';ModuleVersion='2.16.0.0'},@{ModuleName='xNetworking';ModuleVersion='5.7.0.0'},@{ModuleName='xStorage';ModuleVersion='3.2.0.0'},'PSDesiredStateConfiguration'

    Node $AllNodes.NodeName
    {
        WindowsFeature DNS
        {
            Ensure = "Present"
            Name = "DNS"
        }

        WindowsFeature DnsTools
        {
            Ensure = "Present"
            Name = "RSAT-DNS-Server"
            DependsOn = "[WindowsFeature]DNS"
        }

        xDnsServerAddress DnsServerAddress
        {
            Address        = '127.0.0.1'
            InterfaceAlias = $firstNetAdapter.InterfaceAlias
            AddressFamily  = 'IPv4'
            DependsOn = "[WindowsFeature]DNS"
        }

        WindowsFeature ADDSInstall
        {
            Ensure = 'Present'
            Name = 'AD-Domain-Services'
        }
        
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