configuration JumpBoxConfig
{
    Import-DscResource -ModuleName 'PSDesiredStateConfiguration'

    Node $AllNodes.NodeName
    {
        File FileDemo {
            DestinationPath = 'C:\DevOps\readme.txt'
            Ensure = "Present"
            Contents = 'This file was created by Azure Automation DSC'
        }
    }
}