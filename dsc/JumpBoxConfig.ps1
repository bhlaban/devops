configuration JumpBoxConfig
{
    Import-DscResource -ModuleName 'PSDesiredStateConfiguration'

    Node $AllNodes.NodeName
    {
        File AllNodesFile {
            DestinationPath = "C:\readme.txt"
            Ensure = "Present"
            Contents = "This file was created by Azure Automation DSC"
        }
    }
}