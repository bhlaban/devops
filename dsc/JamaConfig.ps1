configuration JamaConfig
{
    Import-DscResource -ModuleName @{ModuleName = 'nx'; ModuleVersion = '1.0'}, 'PSDesiredStateConfiguration'

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