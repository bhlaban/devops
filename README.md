# TFS Deployment with separate VM's for Domain Controller, SQL Server, and TFS

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fbhlaban%2Fdevops%2Fmaster%2Fsampledeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/> 
</a>
<a href="https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fbhlaban%2Fdevops%2Fmaster%2Fsampledeploy.json" target="_blank">
    <img src="http://azuredeploy.net/AzureGov.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2Fbhlaban%2Fdevops%2Fmaster%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/> 
</a>

This template creates a TFS deployment with three VMs. One VM serves as a domain controller for the other two. One of the domain-joined VMs will run SQL Server Standard edition. The second will run TFS, configured to use SQL on the first. All three will support RDP through NAT rules on a load balancer.

## After Deployment

All three VMs are behind a public-facing load balancer with NAT rules enabling RDP. To access TFS you can RDP into any of the VMs using the IP address on the load balancer, and the username & password provided during the deployment. TFS will be available on port 8080 (e.g. http://vmName:8080/tfs)