configuration SqlServerConfig
{
    $domainCredential = Get-AutomationPSCredential -Name "DomainCredential"
    $proGetCredential = Get-AutomationPSCredential -Name "ProGetCredential"
    $sqlInstance = "MSSQLSERVER"
    $proGetDatabaseName = "ProGet"

    Import-DscResource -ModuleName @{ModuleName = 'ComputerManagementDsc'; ModuleVersion = '5.1.0.0'}, @{ModuleName = 'NetworkingDsc'; ModuleVersion = '6.0.0.0'}, @{ModuleName = 'SqlServerDsc'; ModuleVersion = '11.3.0.0'}, 'PSDesiredStateConfiguration'

    Node $AllNodes.NodeName
    {
        Computer JoinDomain
        {
            Name       = $Node.NodeName
            DomainName = $Node.DomainName
            Credential = $domainCredential
        }

        Firewall DatabaseEngineFirewallRule
        {
            Name        = "SQL-Server-Database-Engine-TCP-In"
            DisplayName = "SQL Server Database Engine (TCP-In)"
            Group = "SQL Server"
            Ensure      = "Present"
            Enabled     = "True"
            Direction   = "Inbound"
            LocalPort   = "1433"
            Protocol    = "TCP"
            Description = "Inbound rule for SQL Server to allow TCP traffic for the Database Engine."
        }

        SqlServerLogin DomainAdminSqlServerLogin
        {
            Ensure       = 'Present'
            ServerName   = $Node.NodeName
            InstanceName = $sqlInstance
            LoginType    = 'WindowsUser'
            Name         = $domainCredential.UserName
        }

        SqlServerRole DomainAdminSqlServerRole
        {
            Ensure           = "Present"
            ServerName       = $Node.NodeName
            InstanceName     = $sqlInstance
            ServerRoleName   = "sysadmin"
            MembersToInclude = $domainCredential.UserName
            DependsOn        = "[SqlServerLogin]DomainAdminSqlServerLogin"
        }

        SqlServerLogin ProGetSqlServerLogin
        {
            Ensure       = 'Present'
            ServerName   = $Node.NodeName
            InstanceName = $sqlInstance
            LoginType    = 'WindowsUser'
            Name         = $proGetCredential.UserName
        }

        SqlDatabase ProGetSqlDatabase
        {
            Ensure       = "Present"
            ServerName   = $Node.NodeName
            InstanceName = $sqlInstance
            Name         = $proGetDatabaseName
            DependsOn    = "[SqlServerLogin]ProGetSqlServerLogin"
        }

        SqlDatabaseOwner ProGetSqlDatabaseOwner
        {
            ServerName   = $Node.NodeName
            InstanceName = $sqlInstance
            Database     = $proGetDatabaseName
            Name         = $proGetCredential.UserName
            DependsOn    = "[SqlServerLogin]ProGetSqlServerLogin"
        }
    }
}