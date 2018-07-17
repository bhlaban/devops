configuration JamaConfig
{
    Import-DscResource -ModuleName @{ModuleName='nx';ModuleVersion='1.0'},'PSDesiredStateConfiguration'

    Node localhost
    {
        nxFile ExampleFile
         {
             DestinationPath = "/tmp/example"
             Contents = "hello world"
             Ensure = "Present"
             Type = "File"
         }
    }
}