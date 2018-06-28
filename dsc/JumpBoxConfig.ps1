configuration JumpBoxConfig
{
    Import-DscResource -ModuleName @{ModuleName='cChoco';ModuleVersion='2.3.1.0'},@{ModuleName='xPowerShellExecutionPolicy';ModuleVersion='3.0.0.0'},'PSDesiredStateConfiguration'

    Node $AllNodes.NodeName
    {
        xPowerShellExecutionPolicy ExecutionPolicy
        {
            ExecutionPolicyScope = "LocalMachine"
            ExecutionPolicy      = "RemoteSigned"
        }

        cChocoInstaller InstallChocolatey
        {
            InstallDir = "C:\choco"
            DependsOn = "[xPowerShellExecutionPolicy]ExecutionPolicy"
        }

        cChocoPackageInstaller Putty
        {
            Name = "putty.install"
            DependsOn = "[cChocoInstaller]InstallChocolatey"
        }
    }
}