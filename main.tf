terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0.1"
    }
  }
}

provider "docker" {
  host     = "ssh://root@gideon74.ru:22"
  ssh_opts = ["-o", "StrictHostKeyChecking=no", "-o", "UserKnownHostsFile=/dev/null"]
}

resource "docker_image" "nginx" {
  name         = "nginx:latest"
  keep_locally = false
}

resource "docker_container" "nginx" {
  image   = docker_image.nginx.image_id
  name    = "nginx"
  restart = "unless-stopped"

  networks_advanced {
    name = "web"
  }

  volumes {
    host_path      = "/var/run/docker.sock"
    container_path = "/var/run/docker.sock"
  }

  ports {
    internal = 80
  }

  labels {
    label = "traefik.enable"
    value = "true"
  }

  labels {
    label = "traefik.docker.network"
    value = "web"
  }

  labels {
    label = "traefik.http.routers.nginx.rule"
    value = "Host(`nginx.hozprokat.ru`)"
  }

  labels {
    label = "traefik.http.routers.nginx.entrypoints"
    value = "websecure"
  }

  labels {
    label = "traefik.http.routers.nginx.service"
    value = "nginx"
  }

  labels {
    label = "traefik.http.services.nginx.loadbalancer.server.port"
    value = "80"
  }
}
