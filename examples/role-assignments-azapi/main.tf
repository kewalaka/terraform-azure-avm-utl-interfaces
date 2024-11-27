resource "random_pet" "name" {
  length    = 2
  separator = "-"
}

resource "azapi_resource" "rg" {
  type     = "Microsoft.Resources/resourceGroups@2024-03-01"
  name     = "rg-${random_pet.name.id}"
  location = "swedencentral"
}

# In ordinary usage, the role_assignments attribute value would be set to var.role_assignments.
# However, in this example, we are using a data source in the same module to retrieve the object id.
module "avm_interfaces" {
  source = "../../"
  role_assignments = {
    example = {
      principal_id               = data.azurerm_client_config.current.object_id
      role_definition_id_or_name = "Storage Blob Data Owner"
      scope                      = azapi_resource.rg.id
      principal_type             = "User"
    }
  }
  role_assignment_definition_scope = "/subscriptions/${data.azurerm_client_config.current.subscription_id}"
}

data "azurerm_client_config" "current" {}

resource "azapi_resource" "role_assignments" {
  for_each  = module.avm_interfaces.role_assignments_azapi
  name      = each.value.name
  type      = each.value.type
  body      = each.value.body
  parent_id = azapi_resource.rg.id
}
