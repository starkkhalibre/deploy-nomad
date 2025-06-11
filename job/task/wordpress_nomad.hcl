job "wordpress-deployment" {
  datacenters = ["dc1"]
  type        = "service"

  group "wordpress" {
    count = 1

    network {
      mode = "host"
      port "wordpress" {
        to = 8080
      }
    }

    volume "wordpress_data" {
      type      = "host"
      source    = "wordpress_data"
      read_only = false
    }

    service {
      name     = "wordpress"
      port     = "wordpress"
      provider = "nomad"

      check {
        name     = "wordpress-health"
        type     = "http"
        path     = "/"
        interval = "30s"
        timeout  = "10s"
        method   = "GET"
      }
    }

    task "wordpress" {
      driver = "docker"

      env {
        WORDPRESS_DB_HOST = "127.0.0.1"  # Using service name for Docker DNS
        WORDPRESS_DB_USER = "wpuser"   # Changed from root to wpuser
        WORDPRESS_DB_PASSWORD = "wppassword123"
        WORDPRESS_DB_NAME = "wordpress"
        WORDPRESS_TABLE_PREFIX = "wp_"
        WORDPRESS_DEBUG = "1"
      }

      config {
        image = "wordpress:latest"
        ports = ["wordpress"]
        
        mount {
          type     = "volume"
          target   = "/var/www/html"
          source   = "wordpress_data"
          readonly = false
        }

        command = "bash"
        args = [
          "-c",
          "sed -i 's/Listen 80/Listen 8080/' /etc/apache2/ports.conf && sed -i 's/:80/:8080/' /etc/apache2/sites-available/000-default.conf && apache2-foreground"
        ]
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
