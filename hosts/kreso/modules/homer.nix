{ inputs, config, lib, pkgs, ... }:
let
  configDir = config.dotfiles.configDir;
in {
  virtualisation = {
    oci-containers = {
      backend = "docker";

      containers.homer = {
        image = "b4bz/homer:latest";
        autoStart = true;
        ports = [ "127.0.0.1:8080:8080" ];
        volumes = [
          "/etc/homer/config.yaml:/www/assets/config.yml"
          "/etc/homer/icons:/www/assets/icons"
        ];
      };
    };
  };

  services.traefik = {
    dynamicConfigOptions = {
      http = {
        services = {
          homer.loadBalancer.servers = [ { url = "http://127.0.0.1:8080"; } ];
        };
        routers = {
          homer = {
            rule = "Host(`homer.lan.mislavzanic.xyz`)";
            entryPoints = [ "websecure" ];
            service = "homer";
            tls = true;
          };
        };
      };
    };
  };

  environment.etc = {
    "homer/config.yaml".text = builtins.readFile "${configDir}/homer/config.yaml";
    "homer/icons".source = pkgs.fetchFromGitHub {
      owner = "NX211";
      repo = "homer-icons";
      rev = "fbf21fb";
      sha256 = "sha256-rRGdRPkUPPv7pvIkRl9+XT0EfjD8PNrUGwizycG4KrA=";
    };
  };
}
