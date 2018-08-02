configuration SqlServerConfig
{
    Import-DscResource -ModuleName 'ComputerManagementDsc'
    Import-DscResource -ModuleName 'NetworkingDsc'
    Import-DscResource -ModuleName 'PSDesiredStateConfiguration'
    Import-DscResource -ModuleName 'SqlServerDsc'

    $domainCredential = Get-AutomationPSCredential -Name "DomainCredential"
    $jamaSqlCredential = Get-AutomationPSCredential -Name "JamaSqlCredential"
    $proGetDomainCredential = Get-AutomationPSCredential -Name "ProGetDomainCredential"
    $jamaSqlDatabaseName = "jama"
    $proGetSqlDatabaseName = "proget"
    $sqlInstance = "MSSQLSERVER"
    
    Node $AllNodes.NodeName
    {
        Computer JoinDomain
        {
            Name = $Node.NodeName
            DomainName = $Node.DomainName
            Credential = $domainCredential
        }

        Firewall DatabaseEngineFirewallRule
        {
            Name = "SQL-Server-Database-Engine-TCP-In"
            DisplayName = "SQL Server Database Engine (TCP-In)"
            Group = "SQL Server"
            Ensure = "Present"
            Enabled = "True"
            Direction = "Inbound"
            LocalPort = "1433"
            Protocol = "TCP"
            Description = "Inbound rule for SQL Server to allow TCP traffic for the Database Engine."
        }

        SqlServerLogin DomainAdminSqlServerLogin
        {
            Ensure = 'Present'
            ServerName = $Node.NodeName
            InstanceName = $sqlInstance
            LoginType = 'WindowsUser'
            Name = $domainCredential.UserName
        }

        SqlServerLogin JamaSqlServerLogin
        {
            Ensure = 'Present'
            ServerName = $Node.NodeName
            InstanceName = $sqlInstance
            Name = $jamaSqlCredential.UserName
            LoginType = 'SqlLogin'
            LoginCredential = $jamaSqlCredential
            LoginMustChangePassword = $false
            LoginPasswordExpirationEnabled = $false
        }

        SqlServerLogin ProGetSqlServerLogin
        {
            Ensure       = 'Present'
            ServerName   = $Node.NodeName
            InstanceName = $sqlInstance
            LoginType    = 'WindowsUser'
            Name         = $proGetDomainCredential.UserName
        }

        SqlServerRole DomainAdminSqlServerRole
        {
            Ensure = "Present"
            ServerName = $Node.NodeName
            InstanceName = $sqlInstance
            ServerRoleName = "sysadmin"
            MembersToInclude = $domainCredential.UserName
            DependsOn = "[SqlServerLogin]DomainAdminSqlServerLogin"
        }

        SqlDatabase JamaSqlDatabase
        {
            Ensure       = "Present"
            ServerName   = $Node.NodeName
            InstanceName = $sqlInstance
            Name         = $jamaSqlDatabaseName
            DependsOn    = "[SqlServerLogin]JamaSqlServerLogin"
        }

        SqlDatabaseOwner JamaSqlDatabaseOwner
        {
            ServerName   = $Node.NodeName
            InstanceName = $sqlInstance
            Database     = $jamaSqlDatabaseName
            Name         = $jamaSqlCredential.UserName
            DependsOn    = "[SqlServerLogin]JamaSqlServerLogin"
        }

        SqlDatabase ProGetSqlDatabase
        {
            Ensure       = "Present"
            ServerName   = $Node.NodeName
            InstanceName = $sqlInstance
            Name         = $proGetSqlDatabaseName
            DependsOn    = "[SqlServerLogin]ProGetSqlServerLogin"
        }

        SqlDatabaseOwner ProGetSqlDatabaseOwner
        {
            ServerName   = $Node.NodeName
            InstanceName = $sqlInstance
            Database     = $proGetSqlDatabaseName
            Name         = $proGetDomainCredential.UserName
            DependsOn    = "[SqlServerLogin]ProGetSqlServerLogin"
        }    }
}