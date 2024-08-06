locals {
  coid           = "rush"
  environment    = "p"
  location       = "centralus"
  location_short = "cus"
  function       = "hub"

  hub_address_space         = ["192.168.150.0/24"]
  virtual_wan_address_space = ["192.168.160.0/23"]
}
