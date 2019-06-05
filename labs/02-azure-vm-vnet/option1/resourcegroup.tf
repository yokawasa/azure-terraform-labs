# Create a resource group if it doesn’t exist
resource "azurerm_resource_group" "myterraformgroup" {
    name     = "tflab_02"
    location = "japaneast"

    tags = {
        environment = "Terraform Demo"
    }
}
