{ inputs, config, lib, pkgs, ... }:
{
  virtualisation = {
    docker.enable = true;
    oci-containers = {
      backend = "docker";

      containers.blog = {
        image = "mislavzanic/blog:dev";
        autoStart = true;
        ports = [ "127.0.0.1:8080:8080" ];
      };

      # containers.container-updater = {
      #   image = "mislavzanic/container-updater:dev";
      #   autoStart = true;
      #   volumes = [ "/var/run/docker.sock:/var/run/docker.sock" ];
      #   ports = [ "127.0.0.1:8081:8081" ];
      #   environment = {
      #     DOCKER_API_VERSION = "1.40";
      #   };
      # };

      containers.watchtower = {
        image = "containrrr/watchtower";
        autoStart = true;
        volumes = [ "/var/run/docker.sock:/var/run/docker.sock" ];
        environment = {
          WATCHTOWER_POLL_INTERVAL = "300";
        };
      };
    };
  };
}
