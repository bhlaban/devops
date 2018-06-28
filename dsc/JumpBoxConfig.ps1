configuration JumpBoxConfig
{
    Import-DscResource -ModuleName @{ModuleName = 'cChoco'; ModuleVersion = '2.3.1.0'}, 'PSDesiredStateConfiguration'

    Node $AllNodes.NodeName
    {
        LocalConfigurationManager {
            DebugMode = 'ForceModuleImport'
        }

        cChocoInstaller InstallChoco
        {
            InstallDir = "c:\choco"
        }

        cChocoPackageInstaller InstallChrome
        {
            Name = "googlechrome"
            DependsOn = "[cChocoInstaller]InstallChoco"
        }

        cChocoPackageInstaller InstallPutty
        {
            Name = "putty.install"
            DependsOn = "[cChocoInstaller]InstallChoco"
        }
    }
}