resource "docker_image" "nginx" {
  name = "nginx:latest"
}

resource "docker_container" "webserver" {
  name  = "webserver"
  image = "${docker_image.nginx.name}"

  ports {
    internal = "80"
    external = "80"
  }
}

output "ip" {
  value = "${docker_container.webserver.ip_address}"
}
