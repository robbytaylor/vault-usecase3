provider aws {
  region = var.region
}

provider aws {
  alias  = "secondary"
  region = var.secondary_region
}
