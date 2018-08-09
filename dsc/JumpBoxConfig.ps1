configuration JumpBoxConfig
{
    #Import-DscResource -ModuleName 'cChoco'
    Import-DscResource -ModuleName 'PSDesiredStateConfiguration'

    Node $AllNodes.NodeName
    {
        # cChocoInstaller InstallChoco
        # {
        #     InstallDir = "c:\choco"
        # }

        # cChocoPackageInstaller InstallChrome
        # {
        #     Name = "googlechrome"
        #     Ensure = "Present"
        #     DependsOn = "[cChocoInstaller]InstallChoco"
        # }

        # cChocoPackageInstaller InstallPutty
        # {
        #     Name = "putty.install"
        #     Ensure = "Present"
        #     DependsOn = "[cChocoInstaller]InstallChoco"
        # }

        # cChocoPackageInstaller InstallSqlServerManagementStudio
        # {
        #     Name = "sql-server-management-studio"
        #     Ensure = "Present"
        #     DependsOn = "[cChocoInstaller]InstallChoco"
        # }

        # cChocoPackageInstaller InstallWinSCP
        # {
        #     Name = "winscp"
        #     Ensure = "Present"
        #     DependsOn = "[cChocoInstaller]InstallChoco"
        # }
    }
}