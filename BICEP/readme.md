Azure Virtual Desktop (AVD) Deployment Using Bicep
Overview
This Bicep template (main.bicep) facilitates the deployment of an Azure Virtual Desktop (AVD) solution, including the setup of a host pool, session host VMs, network configurations, and optional features like disk encryption and monitoring integration. The deployment is designed to meet specific requirements such as network isolation and absence of public IP addresses for AVD sessions.

Parameters
Core Deployment Parameters
AzTenantID: Azure Active Directory Tenant ID.
artifactsLocation: Location for artifacts.
AVDResourceGroup: Resource group for AVD deployment.
workspaceLocation: Location for AVD workspace.
Build Options
newBuild: Determines whether to create new AVD resources (default is to join session hosts to existing AVD environment).
update: Combined with newBuild to prevent core AVD resources from deploying during updates.
Optional Features
monitoringAgent: Enables monitoring agent integration.
ephemeral: Determines VMs' use of ephemeral disks.
AADJoin: Specifies Azure AD join for session hosts.
intune: Auto-enrolls session hosts into Intune.
Workspace Configuration
workspaceName: Name of the AVD Workspace.
applicationGroupReferences: List of existing application group resource IDs for the workspace.
Application Group Settings
appGroupFriendlyName: Friendly name for application groups.
desktopName: Friendly name for desktop application groups.
Disk Encryption Settings
keyVaultName: Key Vault name for disk encryption.
keyVaultSKU: Key Vault SKU for disk encryption.
keyType: Key type for encryption.
keySize: Key size for encryption.
diskEncryptionRequired: Specifies if disk encryption is needed.
Host Pool Settings
hostPoolName: Name of the AVD host pool.
hostPoolFriendlyName: Friendly name for the AVD host pool.
hostPoolType: Type of host pool (Pooled or Personal).
personalDesktopAssignmentType: Desktop assignment type for personal host pools.
maxSessionLimit: Maximum session limit for session hosts.
loadBalancerType: Type of load balancer for session hosts.
customRdpProperty: Custom RDP properties for the AVD host pool.
tokenExpirationTime: Expiration time for host pool registration token.
Session Host VM Settings
localAdministratorAccountUserName: Local admin username for session hosts.
localAdministratorAccountPassword: Local admin password for session hosts.
vmResourceGroup: Resource group for session host VMs.
vmLocation: Azure region for session host VMs.
vmSize: VM size for session hosts.
numberOfInstances: Number of session host VM instances.
vmPrefix: Prefix for session host VM names.
vmDiskType: Storage type for session host VM OS disks.
existingVNETResourceGroup: Resource group containing the VNET for session hosts.
existingVNETName: Name of the VNET for session hosts.
existingSubnetName: Name of the subnet for session hosts.
DSC Parameters
assignUsers: Determines if user assignment is required.
defaultUsers: CSV list of default users to assign to AVD application groups.
appID: Application ID for service principal.
appSecret: Application secret for service principal.
Monitoring Integration
logworkspaceSub: Subscription containing Log Analytics Workspace.
logworkspaceResourceGroup: Resource group containing Log Analytics Workspace.
logworkspaceName: Name of Log Analytics Workspace for AVD.
workspaceID: ID of Log Analytics Workspace.
Tags
tagParams: Optional tags for resource categorization.
Variables
logAnalyticsResourceId: Resource ID for Log Analytics Workspace.
Modules
Resource Group Deployment
resourceGroupDeploy: Deploys the core resource group and associated resources.
Data Collection Rules
DCR: Configures Azure Monitor Data Collection Rules for monitoring integration.
AVD Backplane
backPlane: Configures the AVD host pool, application groups, and associated settings.
Disk Encryption Set
diskEncryptionSet: Sets up disk encryption using Azure Key Vault.
Session Host VMs
VMs: Deploys session host VMs into the specified VNET and subnet.
Deployment Process
Overview: Explain the purpose and structure of the Bicep file.
Parameters: Detail each parameter and its significance in the deployment process.
Modules: Describe each module and its role in the overall deployment.
Variables: Explain variables used for dynamic resource configuration.
Deployment Steps: Provide guidance on how to deploy the Bicep template, either manually or through automation pipelines like Azure Pipelines or GitHub Actions.
Notes
This template assumes prerequisites such as existing resource groups, service principals, and network configurations are in place as needed.
Customize parameters and configurations based on specific project requirements and Azure environment constraints.
