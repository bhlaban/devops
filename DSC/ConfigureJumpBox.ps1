configuration ConfigureJumpBox 
{ 
    param 
    ( 
        [Parameter(Mandatory)]
        [String]$DomainName,

        [Parameter(Mandatory)]
        [System.Management.Automation.PSCredential]$Admincreds,

        [Int]$RetryCount = 20,
        [Int]$RetryIntervalSec = 30
    ) 
    
    Node localhost
    {
        LocalConfigurationManager {
            RebootNodeIfNeeded = $true
        }

        #File PuTTYInstaller {
        #    Ensure = "Present"
        #    Type = 'Directory'
        #    DestinationPath = 'C:\Software\PuTTY\putty-0.67-installer.msi'
        #}

        #Package PuTTY
        #{
        #    Ensure = "Present"
        #    Name = "PuTTY"
        #    Path = 'C:\Software\PuTTY\putty-0.67-installer.msi'
        #    ProductId = 'ED9EF59B-0799-428E-823D-6D2B7B4FE2E0'
        #    Arguments = '/qn /norestart'
        #}

    }
} 