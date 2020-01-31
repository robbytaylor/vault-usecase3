terraform {
  backend "consul" {
    address = "34.255.97.99:8500"
    scheme  = "http"
    path    = "terraform/state"
  }
}
