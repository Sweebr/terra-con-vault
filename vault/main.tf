variable basePath {}
variable consul {}
variable repository {}

module "dockerImageHelper" {
    source = "../image-builder"
    name = "vault"
    basePath = "${var.basePath}"
    path = "vault"
    tag = "latest"
    pull = false
    repository = "${var.repository}"
}

resource "docker_container" "vault" {
    name = "vault"
    hostname = "vault"
    image = "${module.dockerImageHelper.dockerImage}"
    must_run = true
    command = [
        "server",
        "-config=/vault/conf.d/vault.hcl"
    ]
    env = [
        "SERVICE_NAME=vault",
        "VAULT_ADDR=http://0.0.0.0:8200"
    ]
    links = [
        "${var.consul}:consul"
    ]
    volumes = {
        host_path = "${path.cwd}/${var.basePath}/vault/assets/conf.d"
        container_path = "/vault/conf.d"
    }
    ports = {
        internal = 8200
        external = 8200
    }
}
