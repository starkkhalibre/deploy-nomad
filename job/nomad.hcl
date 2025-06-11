# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1
# Full configuration options can be found at https://developer.hashicorp.com/nomad/docs/configuration

data_dir  = "/opt/nomad/data"
bind_addr = "0.0.0.0"

server {
  # license_path is required for Nomad Enterprise as of Nomad v1.1.1+
  #license_path = "/etc/nomad.d/license.hclic"
  enabled          = true
  bootstrap_expect = 1
}

client {
  enabled = true
  cni_path = "opt/cni/bin"
  cni_config_dir = "opt/cni/config"
  servers = ["127.0.0.1"]

  host_volume "mariadb_data" {
    path      = "/opt/mysql/data"
    read_only = false
  }

  host_volume "mariadb_config" {
    path      = "/opt/mysql/config"
    read_only = false
  }

  host_volume "wordpress_data" {
    path      = "/opt/wordpress/data"
    read_only = false
  }
  
}

# Add this Docker plugin configuration
plugin "docker" {
  config {
    volumes {
      enabled = true
    }
  }
}
