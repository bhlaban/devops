$configData = @{
    AllNodes = @(
        @{
            NodeName = "*";
            DomainName = "seicdevops.local";
        },
        @{
            NodeName = "dc01";
        }
    )
}

$jsonData = ($configData | ConvertTo-Json -Compress).ToString().Replace("`"", "\`"")

Write-Host "[concat('$jsonData')]"