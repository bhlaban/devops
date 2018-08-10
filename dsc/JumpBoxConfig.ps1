configuration JumpBoxConfig
{
    Import-DscResource -ModuleName 'cChoco'
    Import-DscResource -ModuleName 'PSDesiredStateConfiguration'

    Node $AllNodes.NodeName
    {
        cChocoInstaller InstallChoco
        {
            InstallDir = "c:\choco"
        }
    }
}