//***********************************************************************************************************************
// Core Deployment Parameters
targetScope = 'subscription'

param AzTenantID string = ''
param artifactsLocation string = ''
param AVDResourceGroup string = ''
param workspaceLocation string = ''

//***********************************************************************************************************************
// Core Build Options Update, NewBuild
@description('If true Host Pool, App Group and Workspace will be created. Default is to join Session Hosts to existing AVD environment')
param newBuild bool = false
@description('Combined with newBuild to ensure core AVD resources are not deployed when updating')
param update bool = false

//***********************************************************************************************************************
// Options Azure AD Join, Intune, Ephemeral disks etc
@description('Boolean used to determine if Monitoring agent is needed')
param monitoringAgent bool = false
@description('Whether to use ephemeral disks for VMs')
param ephemeral bool = true
@description('Declares whether Azure AD joined or not')
param AADJoin bool = false
@description('Determines if Session Hosts are auto-enrolled in Intune')
param intune bool = false

//***********************************************************************************************************************
// Workspace
@description('Name of the AVD Workspace to use for this deployment')
param workspaceName string = ''
@description('List of application group resource IDs to be added to Workspace. MUST add existing ones!')
param applicationGroupReferences string = ''

//***********************************************************************************************************************
// Application Group Settings
@description('Application Group Friendly name. This shows in Remote Desktop client.')
param appGroupFriendlyName string
@description('Friendly name of Desktop Application Group. This is shown under Remote Desktop client.')
param desktopName string = ''

//***********************************************************************************************************************
// Disk Encryption Settings - Key Vault etc
@description('Key Vault Name for Disk Encryption.')
param keyVaultName string = ''

@description('Key Vault Disk Encryption SKU')
@allowed([
  'standard'
])
param keyVaultSKU string = 'standard'

@description('The JsonWebKeyType of the key to be created.')
@allowed([
  'EC'
  'EC-HSM'
  'RSA'
  'RSA-HSM'
])
param keyType string = 'RSA'

@description('Key Size.')
param keySize int = 2048

@description('Is Disk Encryption needed.')
param diskEncryptionRequired bool = false

//***********************************************************************************************************************
// Host Pool Settings
@description('Name for Host Pool.')
param hostPoolName string = ''

@description('Friendly Name of the Host Pool, this is visible via the AVD client')
param hostPoolFriendlyName string = ''

@description('Type used for Host Pool.')
@allowed([
  'Pooled'
  'Personal'
])
param hostPoolType string = 'Pooled'

@allowed([
  'Automatic'
  'Direct'
])
param personalDesktopAssignmentType string = 'Direct'

@description('Specify the maximum session limit for the Session Hosts.')
param maxSessionLimit int = 3

@allowed([
  'BreadthFirst'
  'DepthFirst'
  'Persistent'
])
param loadBalancerType string = 'BreadthFirst'

@description('Custom RDP properties to be applied to the AVD Host Pool.')
param customRdpProperty string = 'audiocapturemode:i:1;videoplaybackmode:i:1'

@description('Expiration time for the HostPool registration token. This is only used to configure the Host Pool. The VM deployment generates a token if required.')
param tokenExpirationTime string = '2024-12-31T23:59:59Z'

//***********************************************************************************************************************
// Session Host VM Settings
@description('Local Administrator Login Username for Session Hosts.')
param localAdministratorAccountUserName string = ''

@secure()
@description('Local Administrator Login Password for Session Hosts.')
param localAdministratorAccountPassword string = ''

@description('Resource Group to deploy Session Host VMs into.')
param vmResourceGroup string = ''

@description('Azure Region to deploy VM Session Hosts into.')
param vmLocation string = 'Australia East'

@description('VM Size to be used for Session Host build. E.g. Standard_D2s_v3')
param vmSize string = 'Standard_D4s_v5'

@description('Number of Session Host VMs required.')
param numberOfInstances int = 3

@description('Current number of Session Host VMs. Populated automatically for upgrade build. Do not edit.')
param currentInstances int = 0

@description('Prefix to use for Session Host VM build. Build will add the version details to this. E.g. AVD-PROD-11-0-x X being machine number.')
param vmPrefix string = ''

@description('Required storage type for Session Host VM OS disk.')
@allowed([
  'Standard_LRS'
  'Premium_LRS'
])
param vmDiskType string = 'Premium_LRS'

@description('Resource Group containing the VNET to which to join Session Host VMs.')
param existingVNETResourceGroup string = ''

@description('Name of the VNET that the Session Host VMs will be connected to.')
param existingVNETName string = ''

@description('The name of the relevant VNET Subnet that is to be used for deployment.')
param existingSubnetName string = ''

//***********************************************************************************************************************
// DSC Parameters
@description('Parameter to determine if user assignment is required. If true, defaultUsers will be used.')
param assignUsers string = ''

@description('CSV list of default users to assign to AVD Application Group.')
param defaultUsers string = ''

@description('Application ID for Service Principal. Used for DSC scripts.')
param appID string = ''

@description('Application Secret for Service Principal.')
@secure()
param appSecret string = ''

//***********************************************************************************************************************
// Used for Monitoring Module
@description('Subscription that Log Analytics Workspace is located in.')
param logworkspaceSub string = ''

@description('Resource Group that Log Analytics Workspace is located in.')
param logworkspaceResourceGroup string = ''

@description('Name of Log Analytics Workspace for AVD to be joined to.')
param logworkspaceName string = ''

@description('Log Analytics Workspace ID')
param workspaceID string = ''

@description('Log Analytics Workspace Key')
param workspaceKey string = ''

param tagParams object

//***********************************************************************************************************************
// Variables - All
var logAnalyticsResourceId = '/subscriptions/${logworkspaceSub}/resourceGroups/${logworkspaceResourceGroup}/providers/Microsoft.OperationalInsights/workspaces/${logworkspaceName}'

//***********************************************************************************************************************
// Modules - Resource Group, DCR, AVD Backplane, VMs
module resourceGroupDeploy './modules/resourceGroup.bicep' = {
  name: 'resourceGroup'
  scope: subscription()
  params: {
    AVDResourceGroup: AVDResourceGroup
    AVDlocation: workspaceLocation
    vmResourceGroup: vmResourceGroup
    VMlocation: vmLocation
  }
}

module DCR './modules/DCR.bicep' = {
  name: 'DCR'
  scope: resourceGroup('AzureMonitor-DataCollectionRules')
  params: {
    location: workspaceLocation
    monitoringAgent: monitoringAgent
    logAnalyticsResourceId: logAnalyticsResourceId
    workspaceID: workspaceID
  }
  dependsOn: [
    resourceGroupDeploy
  ]
}

module backPlane './modules/backPlane.bicep' = {
  name: 'backPlane'
  scope: resourceGroup(AVDResourceGroup)
  params: {
    location: workspaceLocation
    workspaceLocation: workspaceLocation
    logworkspaceSub: logworkspaceSub
    logworkspaceResourceGroup: logworkspaceResourceGroup
    logworkspaceName: logworkspaceName
    hostPoolName: hostPoolName
    hostPoolFriendlyName: hostPoolFriendlyName
    hostPoolType: hostPoolType
    appGroupFriendlyName: appGroupFriendlyName
    applicationGroupReferences: applicationGroupReferences
    loadBalancerType: loadBalancerType
    workspaceName: workspaceName
    personalDesktopAssignmentType: personalDesktopAssignmentType
    customRdpProperty: customRdpProperty
    tokenExpirationTime: tokenExpirationTime
    maxSessionLimit: maxSessionLimit
    newBuild: newBuild
    update: update
  }
  dependsOn: [
    resourceGroupDeploy
  ]
}

module diskEncryptionSet './modules/DiskEncryption.bicep' = {
  name: 'DiskEncryptionSet'
  scope: resourceGroup(vmResourceGroup)
  params: {
    location: vmLocation
    keyVaultName: keyVaultName
    keyVaultSKU: keyVaultSKU
    keyType: keyType
    keySize: keySize
  }
  dependsOn: [
    resourceGroupDeploy
  ]
}

module VMswithLA './modules/VMs.bicep' = {
  name: 'VMs'
  scope: resourceGroup(vmResourceGroup)
  params: {
    AzTenantID: AzTenantID
    location: vmLocation
    administratorAccountUserName: localAdministratorAccountUserName
    administratorAccountPassword: localAdministratorAccountPassword
    localAdministratorAccountUserName: localAdministratorAccountUserName
    localAdministratorAccountPassword: localAdministratorAccountPassword
    artifactsLocation: artifactsLocation
    vmDiskType: vmDiskType
    vmPrefix: vmPrefix
    vmSize: vmSize
    currentInstances: currentInstances
    AVDnumberOfInstances: numberOfInstances
    existingVNETResourceGroup: existingVNETResourceGroup
    existingVNETName: existingVNETName
    existingSubnetName: existingSubnetName
    hostPoolName: hostPoolName
    ouPath: 'WORKGROUP' // Set to WORKGROUP for local accounts
    appGroupName: reference(resourceId('Microsoft.Resources/deployments', 'backPlane'), '2019-10-01').outputs.appGroupName.value
    appID: appID
    appSecret: appSecret
    assignUsers: assignUsers
    defaultUsers: defaultUsers
    desktopName: desktopName
    resourceGroupName: AVDResourceGroup
    DCRId: DCR.outputs.DCRId
    logAnalyticsResourceId: logAnalyticsResourceId
    workspaceID: ''
    workspaceKey: workspaceKey
    tagParams: tagParams
    monitoringAgent: monitoringAgent
    ephemeral: ephemeral
    AADJoin: AADJoin
    intune: intune
    keyUrl: diskEncryptionSet.outputs.keyUrl
    keyVaultResourceId: diskEncryptionRequired ? diskEncryptionSet.outputs.keyVaultResourceId : 'null'
    keyVaultUrl: diskEncryptionRequired ? diskEncryptionSet.outputs.keyVaultUrl : 'null'
    diskEncryptionRequired: diskEncryptionRequired
    trustedLaunch: false // or false depending on your requirements
    domainToJoin: ''
    sharedImageGalleryDefinitionname: ''
    sharedImageGalleryName: ''
    sharedImageGalleryResourceGroup: ''
    sharedImageGallerySubscription: ''
    sharedImageGalleryVersionName: ''
    
  }

  dependsOn: [
    backPlane
    diskEncryptionSet
  ]
}
