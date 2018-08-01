configuration JumpBoxConfig
{
    Import-DscResource -ModuleName @{ModuleName = 'cChoco'; ModuleVersion = '2.3.1.0'}, 'PSDesiredStateConfiguration'

    Node $AllNodes.NodeName
    {
        cChocoInstaller InstallChoco
        {
            InstallDir = "c:\choco"
        }

        cChocoPackageInstaller InstallChrome
        {
            Name      = "googlechrome"
            Ensure    = "Present"
            DependsOn = "[cChocoInstaller]InstallChoco"
        }

        cChocoPackageInstaller InstallPutty
        {
            Name      = "putty.install"
            Ensure    = "Present"
            DependsOn = "[cChocoInstaller]InstallChoco"
        }

        cChocoPackageInstaller InstallSqlServerManagementStudio
        {
            Name      = "sql-server-management-studio"
            Ensure    = "Present"
            DependsOn = "[cChocoInstaller]InstallChoco"
        }

        cChocoPackageInstaller InstallWinSCP
        {
            Name      = "winscp"
            Ensure    = "Present"
            DependsOn = "[cChocoInstaller]InstallChoco"
        }
    }
}