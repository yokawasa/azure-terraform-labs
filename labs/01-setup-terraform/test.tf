provider "azurerm" {
}
resource "azurerm_resource_group" "test" {
        name = "tflab_01"
        location = "japaneast"
}


