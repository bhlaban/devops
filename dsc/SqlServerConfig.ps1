configuration SqlServerConfig
{
    $domainCredential = Get-AutomationPSCredential -Name "DomainCredential"

    Import-DscResource -ModuleName @{ModuleName='ComputerManagementDsc';ModuleVersion='5.1.0.0'},@{ModuleName='SqlServerDsc';ModuleVersion='11.3.0.0'},'PSDesiredStateConfiguration'

    Node $AllNodes.NodeName
    {
        Computer JoinDomain
        {
            Name = $Node.NodeName
            DomainName = $Node.DomainName
            Credential = $domainCredential
        }

        SqlServerLogin AddDomainAdminAccountToSqlServer
        {
            Name = $domainCredential.UserName
            LoginType = "WindowsUser"
			ServerName = $Node.NodeName
			InstanceName = "MSSQLSERVER"
        }

		SqlServerRole AddDomainAdminAccountToSysAdmin
        {
			Ensure = "Present"
            MembersToInclude = $domainCredential.UserName
            ServerRoleName = "sysadmin"
			ServerName = $Node.NodeName
			InstanceName = "MSSQLSERVER"
			DependsOn = "[SqlServerLogin]AddDomainAdminAccountToSqlServer"
        }
    }
}