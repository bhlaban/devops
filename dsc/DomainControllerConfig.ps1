configuration DomainControllerConfig
{
    $domainCredential = Get-AutomationPSCredential -Name "DomainCredential"
    $proGetCredential = Get-AutomationPSCredential -Name "ProGetCredential"

    Import-DscResource -ModuleName @{ModuleName='xActiveDirectory';ModuleVersion='2.16.0.0'},@{ModuleName='xStorage';ModuleVersion='3.2.0.0'},'PSDesiredStateConfiguration'

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

        WindowsFeature ADDS
        {
            Ensure = 'Present'
            Name = 'AD-Domain-Services'
            IncludeAllSubFeature = $true
        }
        
        WindowsFeature RSAT-Tools
        {
            Ensure = "Present"
            Name = "RSAT"
            IncludeAllSubFeature = $true
            DependsOn = "[WindowsFeature]ADDS"
        }

        xADDomain Domain
        {
            DomainName = $Node.DomainName
            DomainAdministratorCredential = $domainCredential
            SafemodeAdministratorPassword = $domainCredential
            DatabasePath = 'F:\NTDS'
            LogPath = 'F:\NTDS'
            SysvolPath = 'F:\SYSVOL'
            DependsOn = '[WindowsFeature]ADDS'
        }

        xWaitForADDomain WaitForDomain
        {
            DomainName = $Node.DomainName
            DomainUserCredential = $domainCredential
            RetryCount = 60
            RetryIntervalSec = 60
            DependsOn = "[xADDomain]Domain"
        }

        xADUser ProGetUser
        {
            DomainName = $Node.DomainName
            DomainAdministratorCredential = $domainCredential
            UserName = $proGetCredential.UserName
            Password = $proGetCredential
            Ensure = "Present"
            DependsOn = "[xWaitForADDomain]WaitForDomain"
        }
   }
}