configuration DomainControllerConfig
{
    $domainCredential = Get-AutomationPSCredential domainCredential

    Import-DscResource -ModuleName @{ModuleName='xActiveDirectory';ModuleVersion='2.16.0.0';GUID='9FECD4F6-8F02-4707-99B3-539E940E9FF5'},@{ModuleName='xStorage';ModuleVersion='3.2.0.0';GUID='00d73ca1-58b5-46b7-ac1a-5bfcf5814faf'},'PSDesiredStateConfiguration'

    Node $AllNodes.NodeName
    {
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