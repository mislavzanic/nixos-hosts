{ inputs, config, lib, pkgs, ... }:
{
  networking.firewall.allowedTCPPorts = [ 80 443 ];

  services.traefik = {
    enable = true;

    dynamicConfigOptions = {

      http.middlewares.redirect-to-https.redirectscheme = {
        scheme = "https";
        permanent = true;
      };

      http = {
        services = {
          blog.loadBalancer.servers = [ { url = "http://127.0.0.1:8080"; } ];
          container-updater.loadBalancer.servers = [ { url = "http://127.0.0.1:8081"; } ];
        };

        routers = {
          blog = {
            rule = "Host(`mislavzanic.com`)";
            entryPoints = [ "websecure" ];
            service = "blog";
            tls.certResolver = "letsencrypt";
          };
          container-updater = {
            rule = "Host(`webhook.mislavzanic.com`)";
            entryPoints = [ "websecure" ];
            service = "container-updater";
            tls.certResolver = "letsencrypt";
          };
        };
      };
    };

    staticConfigOptions = {
      global = {
        checkNewVersion = false;
        sendAnonymousUsage = false;
      };

      entryPoints = {
        web = {
          address = ":80";
          http = {
            redirections.entrypoint = {
              to = "websecure";
              scheme = "https";
            };
          };
        };
        websecure.address = ":443";
      };

      certificatesResolvers = {
        letsencrypt.acme = {
          email = "mislavzanic3@gmail.com";
          storage = "/var/lib/traefik/cert.json";
          httpChallenge = {
            entryPoint = "web";
          };
        };
      };
    };
  };
}
