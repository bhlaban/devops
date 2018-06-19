configuration SqlServerConfig
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

    Import-DscResource -ModuleName xActiveDirectory, xComputerManagement, xNetworking, SqlServerDsc

    $DomainCreds = Get-AutomationPSCredential -Name $CredentialName

    Node localhost
    {
        LocalConfigurationManager 
        {
            RebootNodeIfNeeded = $true
        }

		xFirewall DatabaseEngineFirewallRule
        {
            Direction = "Inbound"
            Name = "SQL-Server-Database-Engine-TCP-In"
            DisplayName = "SQL Server Database Engine (TCP-In)"
            Description = "Inbound rule for SQL Server to allow TCP traffic for the Database Engine."
            Group = "SQL Server"
            Enabled = "True"
            Protocol = "TCP"
            LocalPort = "1433"
            Ensure = "Present"
        }

        WindowsFeature ADPS
        {
            Name = "RSAT-AD-PowerShell"
            Ensure = "Present"
        }

        xWaitForADDomain DscForestWait 
        { 
            DomainName = $DomainName 
            DomainUserCredential= $DomainCreds
            RetryCount = 20
            RetryIntervalSec = 30
	        DependsOn = "[WindowsFeature]ADPS"
        }
        
        xComputer DomainJoin
        {
            Name = $env:COMPUTERNAME
            DomainName = $DomainName
            Credential = $DomainCreds
	        DependsOn = "[xWaitForADDomain]DscForestWait"
        }

        SqlServerLogin AddDomainAdminAccountToSqlServer
        {
            Ensure = "Present"
            Name = $DomainCreds.UserName
            LoginType = "WindowsUser"
			ServerName = $env:COMPUTERNAME
			InstanceName = $env:COMPUTERNAME
        }

		SqlServerRole AddDomainAdminAccountToSysAdmin
        {
			Ensure = "Present"
            MembersToInclude = $DomainCreds.UserName
            ServerRoleName = "sysadmin"
			ServerName = $env:COMPUTERNAME
			InstanceName = $env:COMPUTERNAME
			DependsOn = "[SqlServerLogin]AddDomainAdminAccountToSqlServer"
        }
    }
}