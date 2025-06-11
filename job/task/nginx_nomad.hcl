# nginx-deployment.nomad
job "nginx-deployment" {
  datacenters = ["dc1"]
  type        = "service"

  group "nginx" {
    count = 1

    network {
      mode = "host"
      port "nginx" {
        static = 80
      }
    }

    service {
      name     = "nginx-service"
      port     = "nginx"
      provider = "nomad"

      check {
        name     = "health-check"
        type     = "http"
        path     = "/"
        interval = "30s"
        timeout  = "10s"
        method   = "GET"
      }
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
        volumes = [
          "local/nginx.conf:/etc/nginx/conf.d/default.conf"
        ]
      }

      template {
        data = <<EOF
        server {
            listen 80;
            server_name localhost;

            location / {
                proxy_pass http://{{ range nomadService "wordpress" }}{{ .Address }}:{{ .Port }}{{ end }};
                proxy_set_header Host $host;
                proxy_set_header X-Real-IP $remote_addr;
                proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
                proxy_set_header X-Forwarded-Proto $scheme;
            }
        }
        EOF
        destination = "local/nginx.conf"
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
