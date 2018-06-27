Login-AzureRmAccount -Environment AzureUSGovernment

$location = 'usgovvirginia'
$resourceGroupName = 'seicdevops-rg'
$domainName = 'seicdevops.local'
$adminUsername = 'superuser'
$adminPassword = ConvertTo-SecureString 'P@$$word12345' -AsPlainText -Force
$compileDateTime = Get-Date -Format g

Get-AzureRmResourceGroup -Name $resourceGroupName -ErrorVariable notPresent -ErrorAction SilentlyContinue

if ($notPresent)
{
    New-AzureRmResourceGroup -Name $resourceGroupName -Location $location
}

$templateUri = $(Get-GitHubRawPath -File .\azuredeploy.json)

$templateParameterObject = @{}
$templateParameterObject.Add("domainName", $domainName)
$templateParameterObject.Add("adminUsername", $adminUsername)
$templateParameterObject.Add("adminPassword", $adminPassword)
$templateParameterObject.Add("compileDateTime", $compileDateTime)

New-AzureRmResourceGroupDeployment -Name seicdevops-deploy -ResourceGroupName $resourceGroupName -TemplateUri $templateUri -TemplateParameterObject $templateParameterObject