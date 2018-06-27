configuration JumpBoxConfig
{
    Import-DscResource -ModuleName 'PSDesiredStateConfiguration'

    Node $AllNodes.NodeName
    {
        File AllNodesFile {
            DestinationPath = "C:\Deploy.txt"
            Ensure = "Present"
            Contents = "AllNodes.DomainName: $AllNodes.DomainName AllNodes.Message: $AllNodes.Message Node.Message: $Node.Message Node.ComputerName: $Node.ComputerName"
        }
    }
}