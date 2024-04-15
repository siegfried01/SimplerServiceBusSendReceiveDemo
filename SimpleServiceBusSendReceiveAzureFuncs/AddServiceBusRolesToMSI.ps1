# Connect to Azure Account
Connect-AzAccount

# Define the permissions for Service Bus
$permissions = @(
    "Microsoft.ServiceBus/namespaces/queues/send",
    "Microsoft.ServiceBus/namespaces/queues/read",
    "Microsoft.ServiceBus/namespaces/topics/send",
    "Microsoft.ServiceBus/namespaces/topics/read",
    "Microsoft.ServiceBus/namespaces/topics/subscriptions/read",
    "Microsoft.ServiceBus/namespaces/topics/subscriptions/trigger",
    "Microsoft.ServiceBus/namespaces/topics/subscriptions/rules/read",
    "Microsoft.ServiceBus/namespaces/topics/subscriptions/rules/write"
)

# Create a custom role definition
New-AzRoleDefinition -Name "Service Bus Reader/Writer" -Description "Can read from and write to Service Bus" -Actions $permissions -AssignableScope "/subscriptions/<subscription-id>"

# Define variables
$resourceGroupName = "YourResourceGroupName"
$serviceBusNamespaceName = "YourServiceBusNamespaceName"
$roleDefinitionName = "Service Bus Reader/Writer" # This should match the name of the role definition you created earlier

# Get the Service Bus namespace resource
$serviceBusNamespace = Get-AzServiceBusNamespace -ResourceGroupName $resourceGroupName -Name $serviceBusNamespaceName

# Get the system managed identity associated with the Service Bus namespace
$managedIdentity = Get-AzResource -ResourceId $serviceBusNamespace.Identity.PrincipalId

# Assign the role to the system managed identity
New-AzRoleAssignment -ObjectId $managedIdentity.Properties.principalId -RoleDefinitionName $roleDefinitionName -Scope $serviceBusNamespace.Id
