configuration DomainControllerConfig
{
   param
   (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [String] $DomainName,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [String] $CredentialName
    )

    Import-DscResource -ModuleName PSDesiredStateConfiguration, xActiveDirectory, xNetworking, xPendingReboot, xStorage
    
    $DomainCreds = Get-AutomationPSCredential -Name $CredentialName

    Node localhost
    {
        LocalConfigurationManager
        {
            RebootNodeIfNeeded = $true
        }

        WindowsFeature DNS
        {
            Ensure = "Present"
            Name = "DNS"
        }

        Script EnableDNSDiags
        {
      	    SetScript = {
                Set-DnsServerDiagnostics -All $true
                Write-Verbose -Verbose "Enabling DNS client diagnostics"
            }
            GetScript =  { @{} }
            TestScript = { $false }
            DependsOn = "[WindowsFeature]DNS"
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
            InterfaceAlias = 'Ethernet 3'
            AddressFamily  = 'IPv4'
            DependsOn = "[WindowsFeature]DNS"
        }

        xWaitforDisk Disk3
        {
            DiskId = 3
            RetryIntervalSec = 30
            RetryCount = 20
        }

        xDisk ADDataDisk {
            DiskId = 3
            DriveLetter = "F"
            DependsOn = "[xWaitForDisk]Disk3"
        }

        WindowsFeature ADDSInstall
        {
            Ensure = "Present"
            Name = "AD-Domain-Services"
            DependsOn="[WindowsFeature]DNS"
        }

        WindowsFeature ADDSTools
        {
            Ensure = "Present"
            Name = "RSAT-ADDS-Tools"
            DependsOn = "[WindowsFeature]ADDSInstall"
        }

        WindowsFeature ADAdminCenter
        {
            Ensure = "Present"
            Name = "RSAT-AD-AdminCenter"
            DependsOn = "[WindowsFeature]ADDSTools"
        }

        xADDomain FirstDS
        {
            DomainName = $DomainName
            DomainAdministratorCredential = $DomainCreds
            SafemodeAdministratorPassword = $DomainCreds
            DatabasePath = "F:\NTDS"
            LogPath = "F:\NTDS"
            SysvolPath = "F:\SYSVOL"
            DependsOn = @("[WindowsFeature]ADDSInstall", "[xDisk]ADDataDisk")
        }

        xPendingReboot RebootAfterPromotion{
            Name = "RebootAfterPromotion"
            DependsOn = "[xADDomain]FirstDS"
        }

   }
}