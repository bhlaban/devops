configuration JumpBoxConfig
{
    Import-DscResource -ModuleName @{ModuleName = 'cChoco'; ModuleVersion = '2.3.1.0'}, 'PSDesiredStateConfiguration'

    Node $AllNodes.NodeName
    {
        LocalConfigurationManager {
            DebugMode = 'ForceModuleImport'
        }

        cChocoInstaller installChoco
        {
            InstallDir = "c:\choco"
        }

        cChocoPackageInstaller installChrome
        {
            Name = "googlechrome"
            AutoUpgrade = $True
            DependsOn = "[cChocoInstaller]installChoco"
        }
    }
}