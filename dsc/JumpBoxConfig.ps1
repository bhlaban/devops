configuration JumpBoxConfig
{
    Import-DscResource -ModuleName @{ModuleName='cChoco';ModuleVersion='2.3.1.0'},'PSDesiredStateConfiguration'

    Node $AllNodes.NodeName
    {
        cChocoInstaller InstallChocolatey
        {
            InstallDir = "C:\choco"
        }

        cChocoPackageInstaller Putty
        {
            Name = "putty"
            DependsOn = "[cChocoInstaller]InstallChocolatey"
        }
    }
}