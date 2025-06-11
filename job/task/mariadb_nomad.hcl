job "mariadb-deployment" {
  datacenters = ["dc1"]
  type        = "service"

  group "database" {
    count = 1

    network {
      mode = "host"
      port "mariadb" {
        to = 3306
      }
    }

    volume "mariadb_data" {
      type      = "host"
      source    = "mariadb_data"
      read_only = false
    }

    service {
      name     = "mariadb"
      port     = "mariadb"
      provider = "nomad"

      check {
        name     = "mariadb-health"
        type     = "tcp"
        interval = "30s"
        timeout  = "10s"
      }
    }

    task "mariadb" {
      driver = "docker"

      config {
        image = "mariadb:10.11"
        ports = ["mariadb"]

        mount {
          type     = "volume"
          target   = "/var/lib/mysql"
          source   = "mariadb_data"
          readonly = false
        }
      }

      env {
        MYSQL_ROOT_PASSWORD            = "rootpassword123"
        MYSQL_DATABASE                 = "wordpress"
        MYSQL_USER                     = "wpuser"
        MYSQL_PASSWORD                 = "wppassword123"
        MARIADB_AUTO_UPGRADE           = "1"
        MARIADB_DISABLE_UPGRADE_BACKUP = "1"
        MARIADB_ROOT_HOST              = "%"
      }
      template {
        data        = <<EOF
        [mysqld]
        bind-address = 0.0.0.0
        max_connections = 200
        innodb_buffer_pool_size = 256M
        EOF
        destination = "/etc/mysql/conf.d/99-custom.cnf"
      }

      resources {
        cpu    = 500
        memory = 512
      }

      restart {
        attempts = 3
        interval = "5m"
        delay    = "25s"
        mode     = "fail"
      }
    }
  }
}
