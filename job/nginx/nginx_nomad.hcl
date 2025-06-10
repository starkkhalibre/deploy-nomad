job "nginx-deployment" {

  datacenters = ["dc1"]
  type        = "service"

  group "nginx" {
    count = 2

    network {
      port "nginx" {
        to = 80
      }
    }

    service {
      name     = "nginx-service"
      port     = "nginx"
      provider = "nomad"
    }

    restart {
      attempts = 2
      interval = "30m"
      delay    = "15s"
      mode     = "fail"
    }

    task "nginx" {
      driver = "docker"

      config {
        image = "nginx:latest"
        ports = ["nginx"]
        # volumes = [""]
      }

      logs {
        max_files     = 10
        max_file_size = 15
      }

      resources {
        cpu    = 500
        memory = 256
      }
    }

  }
}
