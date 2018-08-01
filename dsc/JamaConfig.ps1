configuration JamaConfig
{
    Import-DscResource -ModuleName 'nx'
    Import-DscResource -ModuleName 'PSDesiredStateConfiguration'

    Node $AllNodes.NodeName
    {
        nxFile ExampleFile
        {
            DestinationPath = "/tmp/example"
            Contents        = "hello world"
            Ensure          = "Present"
            Type            = "File"
        }
    }
}