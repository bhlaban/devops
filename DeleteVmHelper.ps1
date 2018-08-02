#Login-AzureRmAccount -Environment AzureUSGovernment

$vmsToDelete = @("jama01", "proget01", "tfs01", "tfsagent01")

function Delete-VM {
    
    Param(
        [Parameter(Mandatory=$true, Position=0)]
        [string] $resourceGroupName,
        [Parameter(Mandatory=$true, Position=1)]
        [string] $vmName
    )

    $diskName = $vmName + '-disk-os'
    $nicName = $vmName + '-nic'

    If(Get-AzureRmVM -ResourceGroupName $resourceGroupName -Name $vmName -ErrorAction Ignore) {
        Write-Host "Deleting $vmName."
        Remove-AzureRmVM -ResourceGroupName $resourceGroupName -Name $vmName -Force
        Write-Host "$vmName deleted."
    }
    else {
        Write-Host "$vmName does not exist."
    }

    If(Get-AzureRmDisk -ResourceGroupName $resourceGroupName -Name $diskName -ErrorAction Ignore) {
        Write-Host "Deleting $diskName."
        Remove-AzureRmDisk -ResourceGroupName $resourceGroupName -DiskName $diskName -Force
        Write-Host "$diskName deleted."
    }
    else {
        Write-Host "$diskName does not exist."
    }


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

foreach ($vmToDelete in $vmsToDelete) {
	Delete-VM -resourceGroupName $resourceGroupName -vmName $vmToDelete
}