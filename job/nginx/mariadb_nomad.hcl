job "mariadb-deployment" {
  datacenters = ["dc1"]
  type        = "service"

  group "mariadb" {
    count = 1

    volume "mariadb_data" {
      type      = "host"
      read_only = false
      source    = "mariadb_data"
    }

    network {
      port "mariadb" {
        to = 3306
      }
    }

    service {
      name     = "mariadb-service"
      port     = "mariadb"
      provider = "nomad"
    }

    restart {
      attempts = 2
      interval = "30m"
      delay    = "15s"
      mode     = "fail"
    }

    task "mariadb" {
      driver = "docker"

      env = {
        "MYSQL_ROOT_PASSWORD" = "test"
        "MYSQL_DATABASE"      = "test"
        "MYSQL_USER"          = "test"
        "MYSQL_PASSWORD"      = "test"
      }

      config {
        image = "mariadb:latest"
        ports = ["mariadb"]
      }

      volume_mount {
        volume      = "mariadb_data"
        destination = "/var/lib/mysql"
        read_only = false
      }

      resources {
        cpu    = 500
        memory = 512
      }
    }
  }
}
