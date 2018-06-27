configuration SqlServerConfig
{
    $domainCredential = Get-AutomationPSCredential -Name "DomainCredential"

    Import-DscResource -ModuleName @{ModuleName='ComputerManagementDsc';ModuleVersion='5.1.0.0'},@{ModuleName='SqlServerDsc';ModuleVersion='11.3.0.0'},'PSDesiredStateConfiguration'

    Node $AllNodes.NodeName
    {
        Computer JoinDomain
        {
            Name = $Node.ComputerName
            DomainName = $Node.DomainName
            Credential = $domainCredential
        }

        SqlServerLogin AddDomainAdminAccountToSqlServer
        {
            Name = $domainCredential.UserName
            LoginType = "WindowsUser"
			ServerName = $Node.ComputerName
			InstanceName = $Node.ComputerName
        }

		SqlServerRole AddDomainAdminAccountToSysAdmin
        {
			Ensure = "Present"
            MembersToInclude = $domainCredential.UserName
            ServerRoleName = "sysadmin"
			ServerName = $Node.ComputerName
			InstanceName = $Node.ComputerName
			DependsOn = "[SqlServerLogin]AddDomainAdminAccountToSqlServer"
        }
    }
}