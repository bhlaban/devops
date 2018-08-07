#Login-AzureRmAccount -Environment AzureUSGovernment

$servicesToDelete = @("Tfs", "TfsAgent")

function Delete-VM {
    
    Param(
        [Parameter(Mandatory=$true, Position=0)]
        [string] $resourceGroupName,
        [Parameter(Mandatory=$true, Position=1)]
        [string] $automationAccountName,
        [Parameter(Mandatory=$true, Position=2)]
        [string] $serviceName
    )

    $vmName = $serviceName + '01'
    $configurationName = $serviceName + 'Config'

    $dscNode = Get-AzureRmAutomationDscNode -ResourceGroupName $resourceGroupName -AutomationAccountName $automationAccountName -Name $vmName -ErrorAction Ignore
    If($dscNode -ne $null) {
        Write-Host "Deleting $vmName DSC node."
        Unregister-AzureRmAutomationDscNode -ResourceGroupName $resourceGroupName -AutomationAccountName $automationAccountName -Id $dscNode.Id
        Write-Host "$vmName DSC node deleted."
    }
    else {
        Write-Host "$vmName DSC node does not exist."
    }

    $nodeConfigurations = Get-AzureRmAutomationDscNodeConfiguration -ResourceGroupName $resourceGroupName -AutomationAccountName $automationAccountName -ErrorAction Ignore
    foreach ($nodeConfiguration in $nodeConfigurations) {
	    if ($nodeConfiguration.ConfigurationName.Contains($configurationName)) {
            Write-Host "Deleting" $nodeConfiguration.Name "DSC node configuration"
            Remove-AzureRmAutomationDscNodeConfiguration -ResourceGroupName $resourceGroupName -AutomationAccountName $automationAccountName -Name $nodeConfiguration.Name -IgnoreNodeMappings -Force
            Write-Host $nodeConfiguration.Name "DSC node configuration deleted."
        }
    }

    If(Get-AzureRmAutomationDscConfiguration -ResourceGroupName $resourceGroupName -AutomationAccountName $automationAccountName -Name $configurationName -ErrorAction Ignore) {
        Write-Host "Deleting $configurationName DSC configuration."
        Remove-AzureRmAutomationDscConfiguration -ResourceGroupName $resourceGroupName -AutomationAccountName $automationAccountName -Name $configurationName -Force
        Write-Host "$configurationName DSC configuration deleted."
    }
    else {
        Write-Host "$configurationName DSC configuration does not exist."
    }

    If(Get-AzureRmVM -ResourceGroupName $resourceGroupName -Name $vmName -ErrorAction Ignore) {
        Write-Host "Deleting $vmName."
        Remove-AzureRmVM -ResourceGroupName $resourceGroupName -Name $vmName -Force
        Write-Host "$vmName deleted."
    }
    else {
        Write-Host "$vmName does not exist."
    }

    $diskName = $vmName + '-disk-os'
    If(Get-AzureRmDisk -ResourceGroupName $resourceGroupName -Name $diskName -ErrorAction Ignore) {
        Write-Host "Deleting $diskName."
        Remove-AzureRmDisk -ResourceGroupName $resourceGroupName -DiskName $diskName -Force
        Write-Host "$diskName deleted."
    }
    else {
        Write-Host "$diskName does not exist."
    }

    $nicName = $vmName + '-nic'
    If(Get-AzureRmNetworkInterface -ResourceGroupName $resourceGroupName -Name $nicName -ErrorAction Ignore) {
        Write-Host "Deleting $nicName."
        Remove-AzureRmNetworkInterface -ResourceGroupName $resourceGroupName -Name $nicName -Force
        Write-Host "$nicName deleted."
    }
    else {
        Write-Host "$nicName does not exist."
    }
}

$resourceGroupName = 'devops-rg'
$automationAccountName = 'automation'

foreach ($serviceToDelete in $servicesToDelete) {
	Delete-VM -resourceGroupName $resourceGroupName -automationAccountName $automationAccountName -serviceName $serviceToDelete
}