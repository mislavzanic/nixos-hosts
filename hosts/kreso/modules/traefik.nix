{ inputs, config, lib, pkgs, ... }:
{
  networking.firewall.allowedTCPPorts = [ 80 443 ];

  users.groups.acme.members = [ "traefik" ];

  security.acme = {
    acceptTerms = true;
    defaults.email = "mislavzanic3@gmail.com";
    certs."lan-wildcard" = {
      email = "mislavzanic3@gmail.com";
      dnsProvider = "cloudflare";
      domain = "*.lan.mislavzanic.xyz";
      credentialsFile = config.age.secrets.dns-env.path;
    };
  };

  services.traefik = {
    enable = true;
    dataDir = "/var/lib/acme";

    dynamicConfigOptions = {
      tls = {
        certificates = [
          {
            certFile = "/var/lib/acme/lan-wildcard/cert.pem";
            keyFile = "/var/lib/acme/lan-wildcard/key.pem";
          }
        ];
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
    };
  };
}
