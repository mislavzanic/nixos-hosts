{ inputs, config, lib, pkgs, ... }:
let
  grafanaServerCfg = config.services.grafana.settings.server;
in {
  services.grafana = {
    enable = true;
    settings.server = {
      domain = "grafana.mislavzanic.com";
      http_addr = "127.0.0.1";
      http_port = 2342;
    };
    settings.security = {
    };
  };

  services.prometheus = {
    enable = true;
    port = 9001;
    scrapeConfigs = [
      {
        job_name = "blog";
        static_configs = [{
          targets = ["127.0.0.1:8080"];
        }];
      }
    ];
  };

  services.traefik.dynamicConfigOptions.http = {
    services.grafana.loadbalancer.servers = [ { url = "http://127.0.0.1:2342"; } ];
    routers.grafana = {
      rule = "Host(`grafana.mislavzanic.com`)";
      entryPoints = [ "websecure" ];
      service = "grafana";
      tls.certResolver = "letsencrypt";
    };
  };
}
