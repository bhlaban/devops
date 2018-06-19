configuration DomainControllerConfig
{
   param
   (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [String] $DomainName = "seicdevops.com",

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [String] $CredentialName = "DomainAdmin"
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
            DatabasePath = "C:\NTDS"
            LogPath = "C:\NTDS"
            SysvolPath = "C:\SYSVOL"
            DependsOn = @("[WindowsFeature]ADDSInstall")
        }

        xPendingReboot RebootAfterPromotion{
            Name = "RebootAfterPromotion"
            DependsOn = "[xADDomain]FirstDS"
        }

   }
}