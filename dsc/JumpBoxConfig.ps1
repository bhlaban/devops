configuration JumpBoxConfig
{
    Import-DscResource -ModuleName @{ModuleName='cChoco';ModuleVersion='2.3.1.0'},@{ModuleName='ComputerManagementDsc';ModuleVersion='5.1.0.0'},'PSDesiredStateConfiguration'

    Node $AllNodes.NodeName
    {
        PowerShellExecutionPolicy ExecutionPolicy
        {
            ExecutionPolicyScope = "LocalMachine"
            ExecutionPolicy      = "RemoteSigned"
        }

        cChocoInstaller InstallChocolatey
        {
            InstallDir = "C:\choco"
            DependsOn = "[PowerShellExecutionPolicy]ExecutionPolicy"
        }

        cChocoPackageInstaller Putty
        {
            Name = "putty.install"
            DependsOn = "[cChocoInstaller]InstallChocolatey"
        }
    }
}